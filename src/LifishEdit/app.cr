require "./level_renderer"
require "./levelset"
require "./mouse_utils"
require "./sidebar"

module LE

# A container for all app components which can be conveniently
# passed around across functions.
# It's a singleton class and cannot be instanced directly.
class App
	getter lr, menu, window, mouse_utils, font, lifish_dir
	property verbose, ls

	def initialize
		@ls = LE::LevelSet.new "#{$lifish_dir}/levels.json"
		@window = SF::RenderWindow.new SF.video_mode(LE::WIN_WIDTH, LE::WIN_HEIGHT), "Lifish Edit"
		@font = SF::Font.from_file "#{$lifish_dir}/assets/fonts/pf_tempesta_seven.ttf"
		@menu = LE::Menu.new @font
		@sidebar = LE::Sidebar.new
		@lr = LE::LevelRenderer.new @ls.next
		@lr.offset = SF.vector2 LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT
		@mouse_utils = LE::MouseUtils.new window, @lr, @menu
	end

	def draw
		@window.draw @sidebar
		@window.draw @menu
		@window.draw @lr
	end
end

end # module LE
