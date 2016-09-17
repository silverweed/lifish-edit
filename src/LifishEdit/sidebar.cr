require "crsfml/graphics"

module LE

class Sidebar
	getter entity_buttons

	macro new_button_if_necessary(name)
		unless nums[{{name}}].includes?(ids.{{name.id}})
			# Save up to 10 ids
			nums[{{name}}][idx[{{name}}]] = ids.{{name.id}}
			idx[{{name}}] += 1
			
			#STDERR.puts "Constructing button #{{{name}}}[#{ids.{{name.id}}}]" 
			btn = CallbackButton.new(@app, {{name}}, ids.{{name.id}}, ->() {
				STDERR.puts("Setting #{{{name}}} to #{ids.{{name.id}}}") if @app.verbose?
				@app.lr.save_level
				@app.lr.set_{{name.id}}(ids.{{name.id}})	
				if {{name}} == :fixed || {{name}} == :breakable
					b = @entity_buttons.find { |bt| bt.entity.type == {{name}} } 
					if b.is_a? EntityButton
						if {{name}} == :fixed
							b.entity.sprite.texture_rect = SF.int_rect(
								LE::TILE_SIZE * (ids.{{name.id}} - 1),
								b.entity.sprite.texture_rect.top, 
								LE::TILE_SIZE, LE::TILE_SIZE)
						else
							b.entity.sprite.texture_rect = SF.int_rect(
								b.entity.sprite.texture_rect.left, 
								LE::TILE_SIZE * (ids.{{name.id}} - 1),
								LE::TILE_SIZE, LE::TILE_SIZE)
						end
					end
				end
				return
			})
			@{{name.id}}_buttons << btn
			btn.position = pos[{{name}}]
			pos[{{name}}] = SF.vector2f(pos[{{name}}].x, pos[{{name}}].y + 1.2 * LE::TILE_SIZE + 1)
		end
	end

	@selected_button : EntityButton?
	@selected_bg : Button?
	@selected_border : Button?
	@selected_fixed : Button?
	@selected_breakable : Button ?

	def initialize(@app : LE::App)
		@rect = SF::RectangleShape.new(SF.vector2f LE::SIDE_PANEL_WIDTH, LE::WIN_HEIGHT)
		@rect.fill_color = SF.color(217, 217, 217)
		@entity_buttons = [] of EntityButton
		@bg_buttons = [] of CallbackButton
		@border_buttons = [] of CallbackButton
		@fixed_buttons = [] of CallbackButton
		@breakable_buttons = [] of CallbackButton
		@backten_button = TextButton.new(@app.font, 
						callback: ->() { 
							@app.lr.save_level
							i = @app.ls.cur_level - 11
							i = @app.ls.n_levels + i if i < 0
							@app.lr.level = @app.ls.set(i)
							return
						}, 
						string: "<< -10",
						width: 2.4 * LE::TILE_SIZE, 
						height: LE::TILE_SIZE)
		@fwten_button = TextButton.new(@app.font, 
						callback: ->() { 
							@app.lr.save_level
							i = (@app.ls.cur_level + 9) % @app.ls.n_levels
							@app.lr.level = @app.ls.set(i)
							return
						},
						string: "+10 >>",
						width: 2.4 * LE::TILE_SIZE, 
						height: LE::TILE_SIZE)
		@time_tweaker = TimeTweaker.new(@app)
		init_buttons
	end

	include SF::Drawable 

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		{% for name in %i(entity bg border fixed breakable) %}
			@{{name.id}}_buttons.map { |btn| btn.draw target, states }
		{% end %}
		target.draw(@backten_button, states)
		target.draw(@fwten_button, states)
		target.draw(@time_tweaker, states)
	end

	def get_touched_button(pos) : SF::Vector2(Float32)?
		@entity_buttons.each do |btn|
			if btn.contains?(pos)
				return btn.position
			end
		end
		{% for name in %w(bg border fixed breakable) %}
			@{{name.id}}_buttons.each do |btn|
				if btn.contains?(pos)
					return btn.position	
				end
			end
		{% end %}
		nil
	end

	# Checks if a touch in position `pos` intercepts a Button and:
	# 	if it's an EntityButton, select it and return it
	#	if it's a BG/Border button, change BG/Border to level and return nil
	def touch(pos) : LE::Entity?
		if @backten_button.contains?(pos)
			@backten_button.callback.call
			return nil
		end
		if @fwten_button.contains?(pos)
			@fwten_button.callback.call
			return nil
		end
		if @time_tweaker.touch(pos)
			return nil
		end
		@entity_buttons.each do |btn|
			if btn.contains?(pos)
				btn.selected = true
				if @selected_button != nil
					@selected_button.not_nil!.selected = false 
				end
				return (@selected_button = btn).entity
			end
		end
		{% for name in %w(bg border fixed breakable) %}
			@{{name.id}}_buttons.each do |btn|
				if btn.contains?(pos)
					STDERR.puts "Callback #{{{name}}}[#{btn.id}]" if @app.verbose?
					if @selected_{{name.id}} != nil
						@selected_{{name.id}}.not_nil!.selected = false
					end	
					btn.callback.call
					btn.selected = true
					@selected_{{name.id}} = btn
					return
				end
			end
		{% end %}
		nil
	end
	
	# Autoselects bg/border/fixed/breakable buttons according to the current level
	def refresh
		refresh_selected
		@time_tweaker.refresh
	end

	private def refresh_selected
		{% for name in %w(bg border fixed breakable) %}
			@selected_{{name.id}}.not_nil!.selected = false if @selected_{{name.id}} != nil
			@selected_{{name.id}} = nil
			@{{name.id}}_buttons.each do |btn|
				if @app.lr.level.tileIDs.{{name.id}} == btn.id
					@selected_{{name.id}} = btn
					btn.selected = true
					break
				end
			end
		{% end %}
	end

	private def init_buttons
		# Entities' buttons
		begin
			pos = SF.vector2f(LE::TILE_SIZE, 2 * LE::TILE_SIZE)
			i = 0
			LE::ENTITIES.each_value do |v|
				next if v == :empty

				btn = 
					if v == :boss
						BossButton.new(@app, v)
					else 
						EntityButton.new(@app, v)
					end
				@entity_buttons << btn
				btn.position = pos
				if i % 2 == 0
					pos.x += 1.2 * LE::TILE_SIZE + 1
				else
					pos.y += 1.2 * LE::TILE_SIZE + 1
					pos.x = LE::TILE_SIZE.to_f32
				end
				i += 1
			end
		end

		# Border/bg buttons
		pos = {
			:bg        => SF.vector2f(3.4 * LE::TILE_SIZE + 10, 2 * LE::TILE_SIZE),
			:border    => SF.vector2f(4.6 * LE::TILE_SIZE + 11, 2 * LE::TILE_SIZE),
			:fixed     => SF.vector2f(5.8 * LE::TILE_SIZE + 12, 2 * LE::TILE_SIZE),
			:breakable => SF.vector2f(7.0 * LE::TILE_SIZE + 13, 2 * LE::TILE_SIZE),
		}
		nums = {
			:bg        => Array(UInt16?).new(10, nil),
			:border    => Array(UInt16?).new(10, nil),
			:fixed     => Array(UInt16?).new(10, nil),
			:breakable => Array(UInt16?).new(10, nil),
		}
		idx = { :bg => 0, :border => 0, :fixed => 0, :breakable => 0 }
		
		@app.ls.data.levels.each do |lv|
			ids = lv.tileIDs
			new_button_if_necessary(:bg)
			new_button_if_necessary(:border)
			new_button_if_necessary(:fixed)
			new_button_if_necessary(:breakable)
		end

		@backten_button.position = SF.vector2f(LE::TILE_SIZE, 
						      @entity_buttons[-1].position.y + 1.2 * LE::TILE_SIZE + 1)
		@fwten_button.position = SF.vector2f(@backten_button.position.x + @backten_button.bounds.width,
						     @backten_button.position.y)
		@time_tweaker.position = @bg_buttons[-1].position + SF.vector2f(0, 1.2 * LE::TILE_SIZE + 1)
	end
	
	class Button
		property selected

		def initialize
			@bg_rect = SF::RectangleShape.new(SF.vector2f(1.2 * LE::TILE_SIZE, 1.2 * LE::TILE_SIZE))
			@bg_rect.fill_color = SF.color(0, 0, 255, 150)
			@bg_rect.outline_thickness = 1
			@bg_rect.outline_color = SF.color(50, 50, 50, 255)
			@selected = false
		end

		def bounds
			@bg_rect.local_bounds
		end

		def position
			@bg_rect.position
		end

		def position=(pos)
			@bg_rect.position = pos
		end

		def contains?(pos)
			@bg_rect.global_bounds.contains?(pos)
		end

		include SF::Drawable 

		def draw(target, states : SF::RenderStates)
			if @selected
				@bg_rect.fill_color = SF.color(0, 0, 255, 150)
			else
				@bg_rect.fill_color = SF.color(0, 0, 0, 0)
			end
			target.draw(@bg_rect, states)
		end
	end

	class TextButton < Button
		getter callback

		def initialize(font, @callback : -> Void, string = "", width = 0, height = 0)
			super()
			@text = SF::Text.new(string, font, 14)
			@text.color = SF::Color::Black
			b = @text.local_bounds
			@bg_rect.size = SF.vector2f([width, b.width + 4].max, [height, b.height + 4].max)
			center_text
			@bg_rect.fill_color = SF::Color::Blue
			@text.color = SF::Color::White
		end

		def fill_color=(col)
			@bg_rect.fill_color = col
		end

		def color=(col)
			@text.color = col
		end
		
		def string=(s)
			@text.string = s
			center_text
		end

		private def center_text
			tb = @text.local_bounds
			rb = @bg_rect.size
			@text.position = @bg_rect.position + SF.vector2f((rb.x - tb.width) / 2, (rb.y - tb.height) / 2)
		end

		def draw(target, states : SF::RenderStates)
			target.draw(@bg_rect, states)
			target.draw(@text, states)
		end

		def position=(pos)
			super
			b = @text.local_bounds
			bs = @bg_rect.size
			@text.position = @bg_rect.position + SF.vector2f((bs.x - b.width) / 2, (bs.y - b.height) / 2)
		end
	end

	class EntityButton < Button
		getter entity

		def initialize(@app : LE::App, entity_sym)
			super()
			@entity = LE::Entity.new(@app, entity_sym, 
						 LE::Data::TileIDs.new(breakable: 1_u16, fixed: 1_u16))
		end

		def draw(target, states : SF::RenderStates)
			super
			target.draw(@entity, states)
		end

		def position=(pos)
			super
			@entity.position = SF.vector2f(pos.x + 0.1 * LE::TILE_SIZE, pos.y + 0.1 * LE::TILE_SIZE)
		end
	end
	
	class BossButton < EntityButton
		def initialize(@app : LE::App, entity_sym)
			super
			@entity.sprite.texture_rect = SF.int_rect(0, 0, 3 * LE::TILE_SIZE, 3 * LE::TILE_SIZE)
			@entity.sprite.scale(SF.vector2f(1.0 / 3, 1.0 / 3))
		end
	end

	class CallbackButton < Button
		getter callback
		getter id

		def initialize(@app : LE::App, type, @id : UInt16, @callback : -> Void)
			super()
			@bg_rect.fill_color = SF.color(0, 0, 0, 0)
			@sprite = SF::Sprite.new
			texture = nil
			begin
				texture = case type
				when :bg
					@app.cache.texture("bg#{id}.png")
				else
					@app.cache.texture("#{type}.png")
				end.as SF::Texture
				@sprite.texture = texture
				@sprite.texture_rect = SF.int_rect(type == :fixed ? (id-1) * LE::TILE_SIZE : 0,
								   type == :bg || type == :fixed ?
									0
									: (id-1) * LE::TILE_SIZE,
								   LE::TILE_SIZE, LE::TILE_SIZE)
			rescue
			end
		end

		def draw(target, states : SF::RenderStates)
			super
			target.draw(@sprite, states)
		end

		def position=(pos)
			super
			@sprite.position = SF.vector2f(pos.x + 0.1 * LE::TILE_SIZE, pos.y + 0.1 * LE::TILE_SIZE)
		end
	end

	class TimeTweaker
		def initialize(@app : LE::App)
			@back_button = TextButton.new(@app.font, ->() { back }, "<", 
						      width: 1.2 * LE::TILE_SIZE, height: 1.2 * LE::TILE_SIZE)
			@back_button.fill_color = SF.color(207, 210, 218)
			@back_button.color = SF::Color::Black
			@fw_button = TextButton.new(@app.font, ->() { fw }, ">",
						      width: 1.2 * LE::TILE_SIZE, height: 1.2 * LE::TILE_SIZE)
			@fw_button.fill_color = SF.color(207, 210, 218)
			@fw_button.color = SF::Color::Black
			@time_displayer = TextButton.new(@app.font, ->() {}, 
							 width: 2.4 * LE::TILE_SIZE + 1, height: 1.2 * LE::TILE_SIZE)
			@time_displayer.fill_color = SF::Color::White
			@time_displayer.color = SF::Color::Black
			@time = Time::Span.new(0, 0, 0)
		end

		def refresh
			@time = Time::Span.new(0, 0, @app.lr.level.time)
			update_time_string
		end

		def position=(pos)
			@back_button.position = pos
			@time_displayer.position = SF.vector2f(@back_button.position.x +
							       @back_button.bounds.width - 1, pos.y)
			@fw_button.position = SF.vector2f(@time_displayer.position.x +
							  @time_displayer.bounds.width - 1, pos.y)
		end

		include SF::Drawable 

		def draw(target, states : SF::RenderStates)
			target.draw(@back_button, states)
			target.draw(@time_displayer, states)
			target.draw(@fw_button, states)
		end

		def touch(pos)
			if @back_button.contains?(pos)
				@back_button.callback.call
				return true
			elsif @fw_button.contains?(pos)
				@fw_button.callback.call
				return true
			end
			false
		end

		private def update_time_string
			@time_displayer.string = "#{@time.minutes}m #{@time.seconds}s"
		end

		private def back
			@app.lr.level.time -= 1 unless @app.lr.level.time == 0
			@time = Time::Span.new(0, 0, @app.lr.level.time)
			update_time_string
			nil
		end

		private def fw 
			@app.lr.level.time += 1
			@time = Time::Span.new(0, 0, @app.lr.level.time)
			update_time_string
			nil
		end

	end
end

end # module LE
