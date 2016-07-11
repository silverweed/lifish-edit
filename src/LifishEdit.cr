# Lifish Edit
# by Giacomo Parolini
#
# Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

options = getopt [
	{ "-v", :verbose }, # whether to be verbose or not
	{ "-V", :version }, # only output program version
	{ "-h", :help },    # only output help
]

if options[:version]
	puts "LifishEdit #{LE::VERSION} by Giacomo Parolini"
	puts "  * compiled with Crystal #{Crystal::VERSION}"
	puts "  * LifishEdit is free software release under the MIT license"
	puts "  * source code available at https://github.com/silverweed/lifish-edit"
	puts "  * get Lifish for free at https://github.com/silverweed/lifish"
	exit 0
end

def help
	puts "Usage: #{$0} [flags] <levelset>"
	puts "flags:"
	puts "        -h: print this help and exit"
	puts "        -v: be verbose"
	puts "        -V: print version and exit"
	exit 0
end

help if options[:help]

args = options[:args] as Array(String)
cfg = LE::Utils.read_cfg_file

STDERR.puts "options: #{options}; args: #{args}"
STDERR.flush

levels_json = ""

if ARGV.size > 0
	levels_json = args[0]
else
	start_dir = cfg["start_dir"]? || ENV["HOME"]
	case LibNFD.open_dialog(nil, start_dir, out levels_json_ptr)
	when LibNFD::Result::ERROR
		raise "Error selecting directory!"
	when LibNFD::Result::CANCEL
		raise "Directory not selected!"
	else
		levels_json = String.new(levels_json_ptr)
	end
end

raise "Invalid levels_json selected!" unless levels_json.size > 0 

app = LE::App.new(levels_json)
app.verbose = !!options[:verbose]
lr = app.lr
window = app.window
ls = app.ls
lr.load_level
app.sidebar.refresh_selected

LE::Utils.write_cfg_file("start_dir", File.dirname(levels_json))

class LE::App
	def place_entity
		tile = mouse_utils.get_touched_tile
		if @selected_entity != nil && tile.is_a? Tuple
			history.save
			lr.place_entity(tile, @selected_entity as LE::Entity)
		end
	end
end

while window.open?
	while event = window.poll_event
		case event.type
		when SF::Event::Closed
			window.close

		when SF::Event::KeyPressed
			case event.key.code
			when SF::KeyCode::Add
				lr.save_level
				lr.level = ls.next
			when SF::KeyCode::Subtract
				lr.save_level
				lr.level = ls.prev
			when SF::KeyCode::Z
				if SF::Keyboard.is_key_pressed(SF::KeyCode::LControl)
					app.history.step_back
				end
			when SF::KeyCode::Y
				if SF::Keyboard.is_key_pressed(SF::KeyCode::LControl)
					app.history.step_forward
				end
			when SF::KeyCode::F
				app.show_fps = !app.show_fps
			end

		when SF::Event::MouseButtonPressed
			touched = app.mouse_utils.get_touched 
			
			if app.verbose
				puts "Mouse in #{SF::Mouse.get_position window};" +
					" tile = #{app.mouse_utils.get_touched_tile};" +
					" touched = #{touched}" 
			end

			if touched.is_a? LE::MenuCallback
				callback = touched as LE::MenuCallback
				exit 0 unless callback.call(app)
			else
				case event.mouse_button.button
				when SF::Mouse::Left
					app.place_entity
				when SF::Mouse::Right
					if touched.is_a? LE::Entity
						app.history.save
						lr.remove_entity(touched) 
					end
				end
			end

		when SF::Event::MouseMoved
			if SF::Mouse.is_button_pressed(SF::Mouse::Left)
				app.place_entity
			elsif SF::Mouse.is_button_pressed(SF::Mouse::Right)
				touched = app.mouse_utils.get_touched
				if touched.is_a? LE::Entity
					app.history.save
					lr.remove_entity(touched) 
				end
			end
		end
	end
	window.clear
	app.draw
	window.display
end
