# Lifish Edit
# by Giacomo Parolini
#
# Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

options = getopt! [
	{ "-l", :levels, String }, # the name of the levelset to load
	{ "-v", :verbose },        # whether to be verbose or not
]
args = options[:args] as Array(String)
cfg = LE::Utils.read_cfg_file

STDERR.puts "options: #{options}; args: #{args}"
STDERR.flush

lifish_dir = ""
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
		lifish_dir = File.dirname(levels_json)
		LE::Utils.write_cfg_file("start_dir", lifish_dir)
	end
end

raise "Invalid levels_json selected!" unless levels_json.size > 0 

app = LE::App.new(levels_json)
app.verbose = options.has_key? :verbose
lr = app.lr
window = app.window
ls = app.ls

while window.open?
	while event = window.poll_event
		case event.type
		when SF::Event::Closed
			window.close
		when SF::Event::KeyPressed
			case event.key.code
			when SF::KeyCode::Add
				lr.level = ls.next
			when SF::KeyCode::Subtract
				lr.level = ls.prev
			end
		when SF::Event::MouseButtonPressed
			puts "Mouse in #{SF::Mouse.get_position window}" if app.verbose
			touched = app.mouse_utils.get_touched 
			case touched
			when LE::Entity
				entity = touched 
				puts entity
				case event.mouse_button.button
				when SF::Mouse::Left
					
				when SF::Mouse::Right
					lr.remove_entity!(entity) if entity.is_a? LE::Entity
				end
			when LE::MenuCallback
				callback = touched 
				exit 0 unless callback.call(app)
			end
		when SF::Event::MouseMoved
			if SF::Mouse.is_button_pressed(SF::Mouse::Left)
				# TODO: put entity
			elsif SF::Mouse.is_button_pressed(SF::Mouse::Right)
				touched = app.mouse_utils.get_touched
				lr.remove_entity!(touched) if touched.is_a? LE::Entity
			end
		end
	end
	window.clear
	app.draw
	window.display
end
