# Lifish Edit
# by Giacomo Parolini
#
# main.cr - Application entry point

require "crsfml/graphics"
require "crsfml/window"
require "./consts"
require "./menu"

getopt! [
	{ "-l", :levels, String }, # the name of the levelset to load
	{ "-v", :verbose },        # whether to be verbose or not
]

STDERR.puts "options: #{$_options}; args: #{$_args}"

if ARGV.size > 1
	$lifish_dir = $_args[0]
else
	start_dir = LE::Utils.read_start_dir || ENV["HOME"]
	case NFD.open_dialog nil, start_dir, out exe
	when NFD::Result::ERROR
		raise "Error selecting directory!"
	when NFD::Result::CANCEL
		raise "Directory not selected!"
	else
		$lifish_dir = File.dirname(String.new exe)
		LE::Utils.write_start_dir $lifish_dir
	end
end

ASSETS_DIR = "#{$lifish_dir}/assets"
$verbose = $_options.has_key? :verbose

ls = LE::LevelSet.new "#{$lifish_dir}/levels.json"

window = SF::RenderWindow.new(SF.video_mode(LE::WIN_WIDTH, LE::WIN_HEIGHT), "Lifish Edit")
font = SF::Font.from_file "#{$lifish_dir}/assets/fonts/pf_tempesta_seven.ttf"

menu = LE::Menu.new
lr = LE::LevelRenderer.new ls.next
lr.offset = SF.vector2 LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT
mouse_utils = LE::MouseUtils.new window, lr

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
			entity = mouse_utils.get_touched_entity 
			puts "Mouse in #{SF::Mouse.get_position window}"
			puts entity
			case event.mouse_button.button
			when SF::Mouse::Left
				
			when SF::Mouse::Right
				lr.remove_entity! entity if entity.is_a? LE::Entity
			end
		end
	end
	window.clear
	window.draw menu
	window.draw lr
	window.display
end
