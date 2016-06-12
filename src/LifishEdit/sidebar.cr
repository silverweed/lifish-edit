require "crsfml/graphics"

module LE

class Sidebar
	getter entity_buttons

	macro new_button_if_necessary(name)
		unless nums[{{name}}].includes?(ids.{{name.id}})
			# Save up to 10 ids
			nums[{{name}}][idx[{{name}}]] = ids.{{name.id}}
			idx[{{name}}] += 1
			
			btn = CallbackButton.new(->() {
				STDERR.puts "Setting #{{{name}}} to #{ids.{{name.id}}}" if @app.verbose
				@app.lr.set_{{name.id}}!(ids.{{name.id}})	
			})
			@{{name.id}}_buttons << btn
			btn.position = pos[{{name}}]
			pos[{{name}}] = SF.vector2f(pos[{{name}}].x, pos[{{name}}].y + 1.2 * LE::TILE_SIZE + 1)
		end
	end

	def initialize(@app : LE::App)
		@rect = SF::RectangleShape.new(SF.vector2f LE::SIDE_PANEL_WIDTH, LE::WIN_HEIGHT)
		@rect.fill_color = SF.color(217, 217, 217)
		@entity_buttons = [] of EntityButton
		@selected_button = nil as EntityButton?
		@bg_buttons = [] of CallbackButton
		@border_buttons = [] of CallbackButton
		@fixed_buttons = [] of CallbackButton
		@breakable_buttons = [] of CallbackButton
		init_buttons
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		{% for name in %i(entity bg border fixed breakable) %}
			@{{name.id}}_buttons.map { |btn| btn.draw target, states }
		{% end %}
	end

	# Checks if a touch in position `pos` intercepts a Button and:
	# 	if it's an EntityButton, select it and return it
	#	if it's a BG/Border button, change BG/Border to level and return nil
	def touch(pos) : LE::Entity?
		@entity_buttons.each do |btn|
			if btn.contains?(pos)
				btn.selected = true
				if @selected_button != nil
					(@selected_button as EntityButton).selected = false 
				end
				return (@selected_button = btn).entity
			end
		end
		{% for name in %w(bg border fixed breakable) %}
			@{{name.id}}_buttons.each do |btn|
				if btn.contains?(pos)
					STDERR.puts "Callback"
					btn.callback
					return
				end
			end
		{% end %}
		nil
	end

	private def init_buttons
		# Entities' buttons
		begin
			pos = SF.vector2f(LE::TILE_SIZE, 2 * LE::TILE_SIZE)
			i = 0
			LE::ENTITIES.each_value do |v|
				btn = EntityButton.new(@app, v)
				@entity_buttons << btn
				btn.position = pos
				if i % 2 == 0
					pos.x += 1.2 * LE::TILE_SIZE + 1
				else
					pos.y += 1.2 * LE::TILE_SIZE + 1
					pos.x = LE::TILE_SIZE
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
	end
	
	class Button
		def initialize()
			@bg_rect = SF::RectangleShape.new(SF.vector2f(1.2 * LE::TILE_SIZE, 1.2 * LE::TILE_SIZE))
			@bg_rect.fill_color = SF.color(0, 0, 255, 150)
			@bg_rect.outline_thickness = 1
			@bg_rect.outline_color = SF.color(50, 50, 50, 255)
		end

		def position=(pos)
			@bg_rect.position = pos
		end

		def contains?(pos)
			@bg_rect.global_bounds.contains pos
		end

		def draw(target, states : SF::RenderStates)
			target.draw(@bg_rect, states)
		end
	end

	class EntityButton < Button
		getter entity
		property selected

		def initialize(@app : LE::App, entity_sym)
			super()
			@entity = LE::Entity.new(@app, entity_sym, LE::Data::TileIDs.new(breakable: 1_u16, fixed: 1_u16))
			@selected = false
		end

		def draw(target, states : SF::RenderStates)
			if @selected
				@bg_rect.fill_color = SF.color(0, 0, 255, 150)
			else
				@bg_rect.fill_color = SF.color(0, 0, 0, 0)
			end
			super
			target.draw(@entity, states)
		end

		def position=(pos)
			super
			@entity.position = SF.vector2f(pos.x + 0.1 * LE::TILE_SIZE, pos.y + 0.1 * LE::TILE_SIZE)
		end
	end

	class CallbackButton < Button
		getter callback

		def initialize(@callback : -> Void)
			super()
			@bg_rect.fill_color = SF.color(0, 0, 0, 0)
		end

		def draw(target, states : SF::RenderStates)
			super
			# TODO
		end
	end
end

end # module LE
