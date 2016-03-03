require "./level_renderer"
require "./levelset"
require "./mouse_utils"
require "./sidebar"
require "./history"

module LE

# A container for all app components which can be conveniently
# passed around across functions.
class App
	getter font, lifish_dir
	property selected_entity
	property verbose

	def initialize(levels_json)
		@lifish_dir = File.dirname(levels_json)
		@ls = LE::LevelSet.new(self, levels_json)
		@window = SF::RenderWindow.new(SF.video_mode(LE::WIN_WIDTH, LE::WIN_HEIGHT), "Lifish Edit")
		@font = SF::Font.from_file("#{@lifish_dir}/assets/fonts/pf_tempesta_seven.ttf")
		@menu = LE::Menu.new(@font)
		@sidebar = LE::Sidebar.new(self)
		@lr = LE::LevelRenderer.new(self, (@ls as LE::LevelSet)[0])
		@mouse_utils = LE::MouseUtils.new(self)
		@history = LE::History.new(self)
		@fps_counter = FPSCounter.new(self)

		(@window as SF::RenderWindow).vertical_sync_enabled = true
		(@lr as LE::LevelRenderer).offset = SF.vector2(LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT)
		(@fps_counter as FPSCounter).position = SF.vector2(2, LE::WIN_HEIGHT - 20)
	end

	def draw
		window.draw sidebar 
		window.draw menu 
		window.draw lr 
		window.draw fps_counter
	end

	def menu
		@menu as LE::Menu
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

	def sidebar
		@sidebar as LE::Sidebar
	end

	def history
		@history as LE::History
	end

	def show_fps
		fps_counter.active
	end

	def show_fps=(active)
		fps_counter.active = active
	end

	private def fps_counter
		@fps_counter as FPSCounter
	end

	class FPSCounter
		INTERVAL = 1000 # ms

		property active

		def initialize(@app, @active = false)
			@updates = 0
			@time = 0
			@clock = SF::Clock.new
			@update_clock = SF::Clock.new
			raise "Font is nil!" if @app.font == nil
			@text = SF::Text.new("?? fps", @app.font as SF::Font, 14)
			@text.color = SF::Color::Black
		end

		def draw(target, states : SF::RenderStates)
			return unless @active
			@updates += 1
			@time += @clock.restart.as_seconds
			if @update_clock.elapsed_time.as_milliseconds >= INTERVAL
				@text.string = "#{(@updates / @time).round} fps"
				@updates = 0
				@time = 0
				@update_clock.restart
			end
			target.draw(@text, states)
		end

		def position=(pos)
			@text.position = pos
		end
	end
end

end # module LE
