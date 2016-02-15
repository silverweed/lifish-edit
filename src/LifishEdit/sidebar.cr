require "crsfml/graphics"

module LE

class Sidebar
	getter buttons

	def initialize(@app)
		@rect = SF::RectangleShape.new(SF.vector2f LE::SIDE_PANEL_WIDTH, LE::WIN_HEIGHT)
		@rect.fill_color = SF.color(217, 217, 217)
		@buttons = [] of Button
		init_buttons
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		@buttons.map { |btn| btn.draw target, states }
	end

	private def init_buttons
		pos = SF.vector2f LE::TILE_SIZE, 2 * LE::TILE_SIZE
		i = 0
		LE::ENTITIES.each_value do |v|
			btn = Button.new(@app, v)
			@buttons << btn
			btn.position = pos
			if i % 2 == 0
				pos.x += 2 * LE::TILE_SIZE
			else
				pos.y += 1.2 * LE::TILE_SIZE
				pos.x = LE::TILE_SIZE
			end
			i += 1
		end
	end
	
	class Button
		getter entity

		def initialize(@app, entity_sym)
			@entity = LE::Entity.new(@app, entity_sym, { "breakable" => 1_i64, "fixed" => 1_i64 })
			@bg_rect = SF::RectangleShape.new(SF.vector2f LE::TILE_SIZE, LE::TILE_SIZE)
			@bg_rect.fill_color = SF.color(150, 150, 150)
		end

		def draw(target, states : SF::RenderStates)
			#target.draw @bg_rect, states
			target.draw(@entity, states)
		end

		def position=(pos)
			@entity.position = pos
		end
	end
end

end # module LE
