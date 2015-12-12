require "./level_renderer"
require "./levelset"
require "./mouse_utils"

module LE

# A container for all app components which can be conveniently
# passed around across functions
class App
	property lr, ls, menu, window, mouse_utils

	def initialize(@lr : LE::LevelRenderer, @ls : LE::LevelSet, @menu : LE::Menu,
		 @window : SF::RenderWindow, @mouse_utils : LE::MouseUtils)
	end

	def draw
		@window.draw @menu
		@window.draw @lr
	end
end

end # module LE
