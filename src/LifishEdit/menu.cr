require "./consts"
require "./app"
require "../clibs/nfd"
require "crsfml/graphics"

module LE

alias MenuCallback = Proc(LE::App, Bool)

class Menu
	# (Name, Button Shape, Button Text, Callback)
	alias ButtonComponents = Tuple(String, SF::RectangleShape, SF::Text, MenuCallback)

	BUTTON_NAMES = ["Save", "Load", "Quit", "<", ">", "Restore", "Rstr All"]
	FONT_SIZE = 16

	property color

	def initialize(@font, @w = LE::WIN_WIDTH, @h = LE::MENU_HEIGHT)
		@rect = SF::RectangleShape.new(SF.vector2f @w, @h)
		@color = SF.color 0, 0, 206
		@rect.fill_color = @color
		@buttons = create_buttons
	end
	
	def draw(target, states : SF::RenderStates)
		target.draw @rect, states
		@buttons.each do |btn|
			target.draw btn[1], states
			target.draw btn[2], states
		end
	end

	def touch(pos) : MenuCallback?
		@buttons.each do |btn|
			return btn[3] if btn[1].global_bounds.contains pos
		end
		nil
	end
	
	private def create_buttons : Array(ButtonComponents)
		btn = [] of ButtonComponents
		x, y, width = 0, 0, @w / BUTTON_NAMES.size
		BUTTON_NAMES.each do |name|
			# The rectangle intercepting mouse clicks
			rect = SF::RectangleShape.new(SF.vector2f width, @h)
			rect.position = SF.vector2f(x, y)
			#rect.fill_color = SF::Color::Transparent
			rect.fill_color = SF.color(0, 0, 180 - x * 50 / width)
			# The menu text
			if @font == nil
				raise "Font is nil!"
			end
			text = SF::Text.new name, (@font as SF::Font), FONT_SIZE
			text.position = rect.position + SF.vector2f(5, 7)
			x += width 
			btn << {name, rect, text, get_callback(name)}
		end
		btn
	end

	private def get_callback(name : String) : MenuCallback
		case name
		when "Save"
			->(app : LE::App) { 
				case NFD.save_dialog("json", app.lifish_dir, out fname)
				when NFD::Result::ERROR
					raise "Error selecting directory!"
				when NFD::Result::CANCEL
				else
					LE::SaveManager.save(app.ls, String.new fname)
				end
				true
			}
		when "Load"
			->(app : LE::App) { 
				case NFD.open_dialog("json", app.lifish_dir, out fname)
				when NFD::Result::ERROR
					raise "Error selecting directory!"
				when NFD::Result::CANCEL
				else
					app.ls = LE::SaveManager.load(app, String.new fname)
				end
				true 
			}
		when "Quit"
			->(app : LE::App) {
				# TODO: confirm
				false
			}
		when "<"
			->(app : LE::App) {
				begin
					app.lr.level = app.ls.prev
					true
				rescue
					false
				end
			}
		when ">"
			->(app : LE::App) {
				begin
					app.lr.level = app.ls.next
					true
				rescue
					false
				end
			}
		when "Restore"
			->(app : LE::App) {
				begin
					app.lr.level.restore!
					app.lr.load_level
					true
				rescue
					false
				end
			}
		when "Rstr All"
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
		else
			raise "Unknown callback: #{name}"
		end
	end
end

end # module LE
