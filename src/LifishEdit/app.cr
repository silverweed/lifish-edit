require "./level_renderer"
require "./levelset"
require "./mouse_utils"
require "./sidebar"
require "./history"
require "./cache"

module LE

# A container for all app components which can be conveniently
# passed around across functions.
class App
	getter lifish_dir
	getter graphics_dir
	getter! font
	getter! menu
	getter! lr
	getter! window
	getter! mouse_utils
	getter! sidebar
	getter! history
	getter! cache
	getter! ls

	setter ls

	property selected_entity
	property? verbose

	@selected_entity : LE::Entity?

	def initialize(levels_json : String, graphics_dir : String?)
		@verbose = false
		@lifish_dir = File.dirname(levels_json)
		@graphics_dir = graphics_dir || "#{@lifish_dir}/assets/graphics"
		@ls = LE::LevelSet.new(self, levels_json)
		@window = SF::RenderWindow.new(SF::VideoMode.new(LE::WIN_WIDTH, LE::WIN_HEIGHT), "Lifish Edit")
		@font = SF::Font.from_file("#{@lifish_dir}/assets/fonts/pf_tempesta_seven.ttf")
		@menu = LE::Menu.new(font.not_nil!)
		@cache = LE::Cache.new(self)
		@sidebar = LE::Sidebar.new(self)
		@lr = LE::LevelRenderer.new(self, ls[0])
		@mouse_utils = LE::MouseUtils.new(self)
		@history = LE::History.new(self)
		@fps_counter = FPSCounter.new(self)

		window.vertical_sync_enabled = true
		lr.offset = SF.vector2f(LE::SIDE_PANEL_WIDTH.to_f32, LE::MENU_HEIGHT.to_f32)
		fps_counter.position = SF.vector2(2, LE::WIN_HEIGHT - 20)
	end

	include SF::Drawable 

	def draw(target, states : SF::RenderStates)
		target.draw(sidebar, states)
		target.draw(menu, states)
		target.draw(lr, states)
		target.draw(fps_counter, states)
	end

	def show_fps
		fps_counter.active
	end

	def show_fps=(active)
		fps_counter.active = active
	end

	private def fps_counter
		@fps_counter.not_nil!
	end

	class FPSCounter
		INTERVAL = SF.seconds(1)

		property active

		def initialize(@app : LE::App, @active = false)
			@updates = 0
			@time = 0_f32 
			@clock = SF::Clock.new
			@update_clock = SF::Clock.new
			raise "Font is nil!" if @app.font == nil
			@text = SF::Text.new("?? fps", @app.font, 14)
			@text.color = SF::Color::Black
		end

		include SF::Drawable

		def draw(target, states : SF::RenderStates)
			return unless @active
			@updates += 1
			@time += @clock.restart.as_seconds
			if @update_clock.elapsed_time >= INTERVAL
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
