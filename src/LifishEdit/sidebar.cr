require "crsfml/graphics"

module LE

class Sidebar
	getter buttons

	def initialize(@app : LE::App)
		@rect = SF::RectangleShape.new(SF.vector2f LE::SIDE_PANEL_WIDTH, LE::WIN_HEIGHT)
		@rect.fill_color = SF.color(217, 217, 217)
		@buttons = [] of Button
		@selected_button = nil as Button?
		init_buttons
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		@buttons.map { |btn| btn.draw target, states }
	end

	# Checks if a touch in position `pos` intercepts a Button and, if so,
	# selects it and returns its entity.
	def touch(pos) : LE::Entity?
		# Unselect any selected button
		(@selected_button as Button).selected = false if @selected_button.is_a? Button
		@selected_button = nil

		@buttons.each do |btn|
			if btn.contains?(pos)
				btn.selected = true
				@selected_button = btn
				break
			end
		end
		
		@selected_button.is_a?(Button) ? (@selected_button as Button).entity : nil
	end

	private def init_buttons
		pos = SF.vector2f(2 * LE::TILE_SIZE, 1.5 * LE::TILE_SIZE)
		i = 0
		LE::ENTITIES.each_value do |v|
			btn = Button.new(@app, v)
			@buttons << btn
			btn.position = pos
			if i % 2 == 0
				pos.x += 2 * LE::TILE_SIZE
			else
				pos.y += 1.2 * LE::TILE_SIZE
				pos.x = 2 * LE::TILE_SIZE
			end
			i += 1
		end
	end
	
	class Button
		getter entity
		property selected

		def initialize(@app : LE::App, entity_sym)
			@entity = LE::Entity.new(@app, entity_sym, LE::Data::TileIDs.new(breakable: 1_u16, fixed: 1_u16))
			@bg_rect = SF::RectangleShape.new(SF.vector2f(1.2 * LE::TILE_SIZE, 1.2 * LE::TILE_SIZE))
			@bg_rect.fill_color = SF.color(0, 0, 255, 150)
			@selected = false
		end

		def draw(target, states : SF::RenderStates)
			if @selected
				target.draw @bg_rect, states
			end
			target.draw(@entity, states)
		end

		def position=(pos)
			@bg_rect.position = pos
			@entity.position = SF.vector2f(pos.x + 0.1 * LE::TILE_SIZE, pos.y + 0.1 * LE::TILE_SIZE)
		end

		def contains?(pos)
			@bg_rect.global_bounds.contains pos
		end
	end
end

end # module LE
