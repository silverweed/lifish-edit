require "crsfml/graphics"
require "./consts"

module LE

class Menu
	property color

	def initialize(@w = LE::WIN_WIDTH, @h = LE::MENU_HEIGHT)
		@rect = SF::RectangleShape.new(SF.vector2f @w, @h)
		@color = SF.color 0, 0, 206
		@rect.fill_color = @color
	end
	
	def draw(target, states : SF::RenderStates)
		target.draw @rect, states
	end
end

end # module LE
