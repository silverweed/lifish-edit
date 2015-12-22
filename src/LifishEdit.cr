# Lifish Edit
# by Giacomo Parolini
#
# main.cr - Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

_options = getopt! [
	{ "-l", :levels, String }, # the name of the levelset to load
	{ "-v", :verbose },        # whether to be verbose or not
]

_args = _options[:args] as Array(String)

STDERR.puts "options: #{_options}; args: #{_args}"
STDERR.flush

if ARGV.size > 0
	$lifish_dir = _args[0]
else
	start_dir = LE::Utils.read_start_dir || ENV["HOME"]
	case NFD.open_dialog nil, start_dir, out exe
	when NFD::Result::ERROR
		raise "Error selecting directory!"
	when NFD::Result::CANCEL
		raise "Directory not selected!"
	else
		$lifish_dir = File.dirname String.new exe
		LE::Utils.write_start_dir $lifish_dir
	end
end

raise "Lifish dir is bogus or nil!" unless $lifish_dir.is_a? String && $lifish_dir.size > 0

app = LE::App.new
app.verbose = _options.has_key? :verbose
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
			puts "Mouse in #{SF::Mouse.get_position window}"
			touched = app.mouse_utils.get_touched 
			case touched
			when LE::Entity
				entity = touched 
				puts entity
				case event.mouse_button.button
				when SF::Mouse::Left
					
				when SF::Mouse::Right
					lr.remove_entity! entity if entity.is_a? LE::Entity
				end
			when LE::MenuCallback
				callback = touched 
				exit 0 unless callback.call app
			end
		when SF::Event::MouseMoved
			if SF::Mouse.is_button_pressed SF::Mouse::Left
				# TODO: put entity
			elsif SF::Mouse.is_button_pressed SF::Mouse::Right
				touched = app.mouse_utils.get_touched
				lr.remove_entity! touched if touched.is_a? LE::Entity
			end
		end
	end
	window.clear
	app.draw
	window.display
end
