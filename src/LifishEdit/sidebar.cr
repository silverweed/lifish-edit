require "crsfml/graphics"
require "./buttons"
require "./time_tweaker"

class LE::Sidebar
	getter entity_buttons, time_tweaker

	macro make_buttons(name)
		(1..8).each do |i|
			btn = BgBorderWallButton.new(@app, ->() {
				@app.lr.save_level
				@app.lr.set_{{name.id}}(i.to_u16)
				if {{name}} == :fixed || {{name}} == :breakable
					b = @entity_buttons.find { |bt| bt.entity.type == {{name}} }
					if b.is_a? LE::EntityButton
						if {{name}} == :fixed
							b.entity.button_sprite.texture_rect = SF.int_rect(
								LE::TILE_SIZE * (i.to_u16 - 1),
								b.entity.button_sprite.texture_rect.top,
								LE::TILE_SIZE, LE::TILE_SIZE)
						else
							b.entity.button_sprite.texture_rect = SF.int_rect(
								b.entity.button_sprite.texture_rect.left,
								LE::TILE_SIZE * (i.to_u16 - 1),
								LE::TILE_SIZE, LE::TILE_SIZE)
						end
					end
				end
				return
			}, {{name}}, i)
			@{{name.id}}_buttons << btn
			btn.position = pos[{{name}}]
			pos[{{name}}] = SF.vector2f(pos[{{name}}].x, pos[{{name}}].y + LE::BUTTONS_WIDTH + 1)
		end
	end

	# Padding of buttons inside side panel
	BUTTONS_PADDING = 11
	ENTITIES_PER_PAGE = 27

	@entity_page = 0
	@max_entity_page = 1

	@selected_button : EntityButton?
	@selected_bg : Button?
	@selected_border : Button?
	@selected_fixed : Button?
	@selected_breakable : Button?

	def initialize(@app : LE::App)
		# Create sidebar background
		@rect = SF::RectangleShape.new(SF.vector2f(LE::SIDE_PANEL_WIDTH, LE::WIN_HEIGHT))
		@rect.fill_color = SF.color(217, 217, 217)
		# and all its content
		@entity_buttons = [] of EntityButton
		@bg_buttons = [] of CallbackButton
		@border_buttons = [] of CallbackButton
		@fixed_buttons = [] of CallbackButton
		@breakable_buttons = [] of CallbackButton
		@effect_buttons = [] of CallbackButton
		@sym_buttons = [] of CallbackButton
		@backpage_button = TextButton.new(@app.font,
						  callback: ->() {
							  change_entity_page(-1)
							  return
						  },
						  string: "< Pre",
						  width: LE::BUTTONS_WIDTH * 3/2,
						  height: LE::TILE_SIZE)
		@fwpage_button = TextButton.new(@app.font,
						  callback: ->() {
							  change_entity_page(1)
							  return
						  },
						  string: "Nxt >",
						  width: LE::BUTTONS_WIDTH * 3/2,
						  height: LE::TILE_SIZE)
		@time_tweaker = TimeTweaker.new(@app)
		@help_text = SF::Text.new("Press H for help", @app.font, 12)
		b = @help_text.local_bounds
		@help_text.position = SF.vector2f(LE::SIDE_PANEL_WIDTH - b.width - 5, LE::WIN_HEIGHT - b.height - 5)
		@help_text.fill_color = SF::Color::Black
		init_buttons
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		{% for name in %i(entity bg border fixed breakable effect sym) %}
			@{{name.id}}_buttons.map { |btn| btn.draw target, states }
		{% end %}
		target.draw(@backpage_button, states)
		target.draw(@fwpage_button, states)
		target.draw(@time_tweaker, states)
		target.draw(@help_text, states)
	end

	# Given a position `pos`, returns the position of the button containing
	# it, or nil if no button contains that `pos`.
	def get_touched_button(pos) : SF::Vector2(Float32)?
		@entity_buttons.each do |btn|
		if btn.contains?(pos)
			return btn.position
		end
	end
	{% for name in %w(bg border fixed breakable effect sym) %}
		@{{name.id}}_buttons.each do |btn|
			if btn.contains?(pos)
				return btn.position
			end
		end
	{% end %}
	{% for name in %w(back fw) %}
		if @time_tweaker.{{name.id}}_button.contains?(pos)
			return @time_tweaker.{{name.id}}_button.position
		end
	{% end %}
	nil
	end

	# Checks if a touch in position `pos` intercepts a Button and:
	# 	if it's an EntityButton, select it and return it
	#	if it's a BG/Border button, change BG/Border to level and return nil
	def touch(pos) : LE::Entity?
		if @backpage_button.contains?(pos)
			@backpage_button.callback.call
			return nil
		end

		if @fwpage_button.contains?(pos)
			@fwpage_button.callback.call
			return nil
		end

		return nil if @time_tweaker.touch(pos)

		@entity_buttons.each do |btn|
			if btn.contains?(pos)
				unless (sb = @selected_button).nil?
					sb.selected = false
				end
				btn.selected = true
				@selected_button = btn
				return btn.entity
			end
		end

		{% for name in %w(bg border fixed breakable effect sym) %}
			@{{name.id}}_buttons.each do |btn|
				if btn.contains?(pos)
					STDERR.puts "Callback #{{{name}}}[#{btn.id}]" if @app.verbose?
			       {% if name != "effect" && name != "sym" %}
				       unless (sel = @selected_{{name.id}}).nil?
					       sel.selected = false
				       end
				       btn.selected = true
				       @selected_{{name.id}} = btn
			       {% end %}
			       btn.callback.call
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
			unless (sel = @selected_{{name.id}}).nil?
				sel.selected = false
			end
			@selected_{{name.id}} = nil
			@{{name.id}}_buttons.each do |btn|
				if @app.lr.level.tileIDs.{{name.id}} == btn.id
					@selected_{{name.id}} = btn
					btn.selected = true
					break
				end
			end
		{% end %}
		fx = @app.lr.level.effects
		@effect_buttons.each_with_index do |btn, i|
			btn.selected = fx.includes?(LE::EFFECTS[i][0].to_s)
		end
		@sym_buttons.each_with_index do |btn, i|
			btn.selected = @app.symmetries.includes?(LE::SYMMETRIES[i][0])
		end
	end

	private def init_buttons
		init_entity_buttons

		# Border/bg buttons
		bp = @entity_buttons[2].position + SF.vector2f(2, 0)
		pos = {
			:bg        => SF.vector2f(bp.x + LE::BUTTONS_WIDTH + 1, bp.y),
			:border    => SF.vector2f(bp.x + 2 * (LE::BUTTONS_WIDTH + 1), bp.y),
			:fixed     => SF.vector2f(bp.x + 3 * (LE::BUTTONS_WIDTH + 1), bp.y),
			:breakable => SF.vector2f(bp.x + 4 * (LE::BUTTONS_WIDTH + 1), bp.y),
		}

		make_buttons(:bg)
		make_buttons(:border)
		make_buttons(:fixed)
		make_buttons(:breakable)

		@backpage_button.position = SF.vector2f(@entity_buttons[0].position.x,
							@entity_buttons[-1].position.y + LE::BUTTONS_WIDTH + 1)
		@fwpage_button.position = SF.vector2f(@backpage_button.position.x + @backpage_button.local_bounds.width - 1,
						      @backpage_button.position.y)
		@time_tweaker.position = @bg_buttons[-1].position + SF.vector2f(0, LE::BUTTONS_WIDTH + 1)

		make_sym_buttons

		# Effects buttons
		fxcb = ->(id : Int32) {
			->() {
				fx = @app.lr.level.effects
				if fx.includes?(LE::EFFECTS[id][0].to_s)
					@app.lr.level.effects.delete(LE::EFFECTS[id][0].to_s)
					@app.feedback_text.show("#{LE::EFFECTS[id][0].to_s} disabled")
					@effect_buttons[id].selected = false
				else
					@app.lr.level.effects << LE::EFFECTS[id][0].to_s
					@app.feedback_text.show("#{LE::EFFECTS[id][0].to_s} enabled")
					@effect_buttons[id].selected = true
				end
				@app.lr.save_level
				nil
			}
		}
		pos = @time_tweaker.position + SF.vector2f(0, LE::BUTTONS_WIDTH + 1)
		2.times do |i|
			btn = EffectButton.new(@app, fxcb.call(i), i)
			btn.position = pos
			pos.x += LE::BUTTONS_WIDTH + 1
			@effect_buttons << btn
		end
	end

	private def init_entity_buttons
		i = 0
		LE::ENTITIES.each_value do |v|
			next if v == :empty

			btn = EntityButton.new(@app, v)
			@entity_buttons << btn
			i += 1
			if i == ENTITIES_PER_PAGE
				i = 0
				@max_entity_page += 1
			end
		end

		position_entity_buttons
	end

	private def position_entity_buttons
		pos = SF.vector2f(BUTTONS_PADDING, LE::MENU_HEIGHT + BUTTONS_PADDING)
		i = 0
		(@entity_page * ENTITIES_PER_PAGE .. (@entity_page + 1) * ENTITIES_PER_PAGE).each do |j|
			break if j >= @entity_buttons.size
			btn = @entity_buttons[j]
			btn.position = pos
			if i % 3 != 2
				pos.x += LE::BUTTONS_WIDTH + 1
			else
				pos.y += LE::BUTTONS_WIDTH + 1
				pos.x = BUTTONS_PADDING.to_f32
			end
			i += 1
		end
	end

	private def clear_entity_buttons_positions
		@entity_buttons.each do |btn|
			btn.position = SF.vector2f(-9999, -9999)
		end
	end

	private def make_sym_buttons
		pos = @backpage_button.position
		pos.y += LE::BUTTONS_WIDTH + 1
		3.times do |i|
			sym = SYMMETRIES[i][0]
			btn = SymmetryButton.new(@app, ->() {
				if @app.symmetries.includes?(sym)
					@app.symmetries.delete(sym)
					@sym_buttons[i].selected = false
				else
					@app.symmetries << sym
					@sym_buttons[i].selected = true
				end
				nil
			}, i)
			btn.position = pos
			@sym_buttons << btn
			pos.x += LE::BUTTONS_WIDTH + 1
		end
	end

	private def change_entity_page(i : Int)
		@entity_page = (@entity_page + i) % @max_entity_page
		clear_entity_buttons_positions
		position_entity_buttons
	end
end
