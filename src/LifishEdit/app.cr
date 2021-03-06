require "./level_renderer"
require "./levelset"
require "./mouse_utils"
require "./sidebar"
require "./history"
require "./cache"
require "./help"
require "./quit_prompt"
require "./feedback_text"

# A container for all app components which can be conveniently
# passed around across functions.
class LE::App
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
	getter! symmetries
	getter! help
	getter! quit_prompt
	getter! feedback_text
	private getter! level_clipboard
	private getter! credit_text
	private getter! credit_text_shade

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
		@menu = LE::Menu.new(font)
		@cache = LE::Cache.new(self)
		@lr = LE::LevelRenderer.new(self, ls[0])
		@sidebar = LE::Sidebar.new(self)
		@mouse_utils = LE::MouseUtils.new(self)
		@history = LE::History.new(self)
		@fps_counter = FPSCounter.new(self)
		@help = LE::Help.new(self)
		@quit_prompt = LE::QuitPrompt.new(self)
		@feedback_text = LE::FeedbackText.new(self)
		@symmetries = [] of Symbol
		@level_clipboard = ""
		@credit_text = SF::Text.new("LifishEdit #{LE::VERSION} by G. Parolini", font, 11)
		begin
			ct = @credit_text.not_nil!
			ct.fill_color = SF::Color::White
			b = ct.local_bounds
			ct.position = SF.vector2f(LE::WIN_WIDTH - b.width - 3, LE::WIN_HEIGHT - b.height - 3)
			@credit_text_shade = SF::Text.new(ct.string, ct.font.not_nil!, ct.character_size)
			cts = @credit_text_shade.not_nil!
			cts.position = ct.position + SF.vector2f(-1, 1)
			cts.fill_color = SF::Color::Black
		end

		window.vertical_sync_enabled = true
		window.framerate_limit = LE::FRAMERATE_LIMIT
		lr.offset = SF.vector2f(LE::SIDE_PANEL_WIDTH.to_f32, LE::MENU_HEIGHT.to_f32)
		fps_counter.position = SF.vector2f(2, LE::WIN_HEIGHT - 20)
	end

	def popups
		[help, quit_prompt]
	end

	def refresh
		# Check long press on time tweaker
		#if SF::Mouse.button_pressed?(SF::Mouse::Left)
			#sidebar.time_tweaker.press(app.mouse_utils.get_touching_time_tweaker, clock.restart)
		#end
		feedback_text.refresh
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(sidebar, states)
		target.draw(menu, states)
		target.draw(lr, states)
		target.draw(help, states)
		target.draw(quit_prompt, states)
		target.draw(fps_counter, states)
		target.draw(feedback_text, states)
		target.draw(credit_text_shade, states)
		target.draw(credit_text, states)
	end

	def show_fps
		fps_counter.active
	end

	def show_fps=(active)
		fps_counter.active = active
	end

	def toggle_help
		help.active = !help.active
	end

	def copy_level
		@level_clipboard = lr.level.tilemap
		feedback_text.show("Level copied to clipboard")
	end

	def paste_level
		return if level_clipboard.size != lr.level.tilemap.size
		history.save
		lr.level.tilemap = level_clipboard
		lr.load_level
		feedback_text.show("Level pasted")
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
