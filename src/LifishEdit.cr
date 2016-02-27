# Lifish Edit
# by Giacomo Parolini
#
# Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

options = getopt [
	{ "-l", :levels, String }, # the name of the levelset to load
	{ "-v", :verbose },        # whether to be verbose or not
]
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
app.verbose = options.has_key? :verbose
lr = app.lr
window = app.window
ls = app.ls

LE::Utils.write_cfg_file("start_dir", File.dirname(levels_json))

class LE::App
	def place_entity
		if @selected_entity != nil
			lr.place_entity!(mouse_utils.get_touched_tile,
					 @selected_entity as LE::Entity)
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
				lr.level = ls.next
			when SF::KeyCode::Subtract
				lr.level = ls.prev
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
					lr.remove_entity!(touched) if touched.is_a? LE::Entity
				end
			end

		when SF::Event::MouseMoved
			if SF::Mouse.is_button_pressed(SF::Mouse::Left)
				app.place_entity
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
