require "./level_renderer"
require "./levelset"
require "./mouse_utils"
require "./sidebar"

module LE

# A container for all app components which can be conveniently
# passed around across functions.
class App
	getter menu, font, lifish_dir
	property verbose

	def initialize(levels_json)
		@lifish_dir = File.dirname(levels_json)
		@ls = LE::LevelSet.new(self, levels_json)
		@window = SF::RenderWindow.new(SF.video_mode(LE::WIN_WIDTH, LE::WIN_HEIGHT), "Lifish Edit")
		@font = SF::Font.from_file("#{@lifish_dir}/assets/fonts/pf_tempesta_seven.ttf")
		@menu = LE::Menu.new(@font)
		@sidebar = LE::Sidebar.new(self)
		@lr = LE::LevelRenderer.new(self, (@ls as LE::LevelSet)[0])
		@mouse_utils = LE::MouseUtils.new(window as SF::RenderWindow, 
						  @lr as LE::LevelRenderer, 
						  @menu as LE::Menu)

		(@window as SF::RenderWindow).vertical_sync_enabled = true
		(@lr as LE::LevelRenderer).offset = SF.vector2(LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT)
	end

	def draw
		w = @window as SF::RenderWindow
		w.draw @sidebar as LE::Sidebar
		w.draw @menu as LE::Menu
		w.draw @lr as LE::LevelRenderer
	end

	def ls
		@ls as LE::LevelSet
	end

	setter ls

	def lr
		@lr as LE::LevelRenderer
	end

	def window
		@window as SF::RenderWindow
	end

	def mouse_utils
		@mouse_utils as LE::MouseUtils
	end
end

end # module LE
