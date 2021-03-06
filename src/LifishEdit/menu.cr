require "./consts"
require "./app"
require "../clibs/nfd"
require "crsfml/graphics"

module LE

# A menu callback is a `Proc` taking a `LE::App` as an argument and returning
# a `Bool`. If `false` is returned, the app exits after the callback.
alias MenuCallback = Proc(LE::App, Bool)

class Menu
	# (Name, Button Shape, Button Text, Callback)
	alias ButtonComponents = Tuple(String, SF::RectangleShape, SF::Text, MenuCallback)

	BUTTON_NAMES = {
		# role,        name,     width_override
		{:save,        "Save"       },
		{:save_as,     "Save as"    },
		{:load,        "Load"       },
		{:back,        "<",       40},
		{:forward,     ">",       40},
		{:restore,     "Restore"    },
		{:restore_all, "Rstr All"   },
		{:clear,       "Clear"      },
		{:quit,        "Quit"       }
	}
	FONT_SIZE = 16

	property color

	def initialize(@font : SF::Font, @w : Int32 = LE::WIN_WIDTH, @h : Int32 = LE::MENU_HEIGHT)
		@rect = SF::RectangleShape.new(SF.vector2f @w, @h)
		@color = SF::Color.new(0, 0, 206)
		@rect.fill_color = @color
		@buttons = create_buttons.as Array(ButtonComponents)
	end
	
	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(@rect, states)
		@buttons.each do |btn|
			target.draw(btn[1], states)
			target.draw(btn[2], states)
		end
	end

	def touch(pos) : MenuCallback?
		@buttons.each do |btn|
			return btn[3] if btn[1].global_bounds.contains?(pos)
		end
		nil
	end

	def invoke(cb : Symbol, app)
		get_callback(cb).call(app)
	end
	
	private def create_buttons : Array(ButtonComponents)
		btn = [] of ButtonComponents
		x, y = 0, 0
		BUTTON_NAMES.each do |b|
			width = 100 # @w / BUTTON_NAMES.size
			if b.size > 2
				width = (b.as Tuple(Symbol, String, Int32))[2]
			end
			# The rectangle intercepting mouse clicks
			rect = SF::RectangleShape.new(SF.vector2f(width, @h))
			rect.position = SF.vector2f(x, y)
			rect.fill_color = SF.color(0, 0, 180 - x * 50 / width)
			# The menu text
			raise "Font is nil!" if @font == nil
			text = SF::Text.new(b[1], @font, FONT_SIZE)
			text.position = rect.position + SF.vector2f(5, 7)
			x += width 
			btn << {b[1], rect, text, get_callback(b[0])}
		end
		btn
	end

	private def show_save_dialog(app : LE::App)
		case LibNFD.save_dialog("json", app.lifish_dir, out fname)
		when LibNFD::Result::ERROR
			raise "Error selecting directory!"
		when LibNFD::Result::CANCEL
		else
			app.lr.save_level
			filename = String.new(fname)
			LE::SaveManager.save(app.ls, filename)
			return filename
		end
		false
	end

	private def get_callback(role : Symbol) : MenuCallback
		case role
		when :save
			->(app : LE::App) {
			begin	
				app.lr.save_level
				LE::SaveManager.save(app.ls, app.ls.json_fname)
				app.feedback_text.show("Saved levels")
				puts "Saved levels in #{app.ls.json_fname}"
			rescue
				begin
					show_save_dialog(app)
					app.feedback_text.show("Saved levels in new file")
				rescue
					app.feedback_text.show("Levels NOT SAVED!")
				end
			end
				true
			}
		when :save_as
			->(app : LE::App) {
				begin
					file = show_save_dialog(app)
					app.ls.json_fname = file if file.is_a? String
					app.feedback_text.show("Saved levels in new file")
				rescue
					app.feedback_text.show("Levels NOT SAVED!")
				end
				true
			}
		when :load
			->(app : LE::App) { 
				case LibNFD.open_dialog("json", app.lifish_dir, out fname)
				when LibNFD::Result::ERROR
					raise "Error selecting directory!"
				when LibNFD::Result::CANCEL
				else
					app.ls = LE::SaveManager.load(app, String.new(fname))
					app.lr.save_level
					app.lr.level = app.ls[0]
				end
				true
			}
		when :quit 
			->(app : LE::App) {
				app.quit_prompt.active = true
			}
		when :back
			->(app : LE::App) {
				begin
					app.lr.save_level
					app.lr.level = app.ls.prev
					true
				rescue
					false
				end
			}
		when :forward 
			->(app : LE::App) {
				begin
					app.lr.level = app.ls.next
					true
				rescue
					false
				end
			}
		when :restore
			->(app : LE::App) {
				begin
					app.lr.level.restore!
					app.lr.load_level
					true
				rescue
					false
				end
			}
		when :restore_all
			->(app : LE::App) {
				app.ls.each do |level|
					level.restore!	
				end
				begin
					app.lr.load_level
					true
				rescue
					false
				end
			}
		when :clear
			->(app : LE::App) {
				app.lr.level.clear!
				app.lr.load_level
				true
			}
		else
			raise "Unknown callback: #{role.to_s}"
		end
	end
end

end # module LE
