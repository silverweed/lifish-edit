require "crsfml/graphics"

module LE

class Sidebar
	getter buttons

	def initialize
		@rect = SF::RectangleShape.new(SF.vector2f SIDE_PANEL_WIDTH, WIN_HEIGHT)
		@rect.fill_color = SF.color 217, 217, 217
		@buttons = [] of Button
		init_buttons
	end

	def draw(target, states : SF::RenderStates)
		target.draw @rect, states
	end

	private def init_buttons
		LE::ENTITIES.each do |k, v|
			@buttons << Button.new v
		end
	end
	
	class Button
		getter entity

		def initialize(entity_sym)
			@entity = LE::Entity.new entity_sym, { "breakable" => 1_i64, "fixed" => 1_i64 }
			@bg_rect = SF::RectangleShape.new(SF.vector2f TILE_SIZE, TILE_SIZE)
			@bg_rect.fill_color = SF.color 150, 150, 150
		end

		def draw(target, states : SF::RenderStates)
			target.draw @bg_rect, states
			target.draw @entity, states
		end
	end
end

end # module LE
