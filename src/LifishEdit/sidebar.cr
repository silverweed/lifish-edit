require "crsfml/graphics"

module LE

class Sidebar
	def initialize
		@rect = SF::RectangleShape.new(SF.vector2f SIDE_PANEL_WIDTH, WIN_HEIGHT)
		@color = SF.color 217, 217, 217
		@rect.fill_color = @color
	end

	def draw(target, states : SF::RenderStates)
		target.draw @rect, states
	end
end

end # module LE
