# Lifish Edit
# by Giacomo Parolini
#
# main.cr - Application entry point

require "crsfml/graphics"
require "crsfml/window"

if ARGV.size < 1
	puts "Usage: #{$0} <lifish_dir>"
	exit 1
end

getopt! [
	{ "-l", :levels, String }, # the name of the levelset to load
	{ "-v", :verbose },        # whether to be verbose or not
]

puts "options: #{$_options}; args: #{$_args}"

LIFISH_DIR = $_args[0]
ASSETS_DIR = "#{LIFISH_DIR}/assets"
WIN_WIDTH = 800
WIN_HEIGHT = 600
$verbose = $_options.has_key? :verbose

ls = LE::LevelSet.new "#{LIFISH_DIR}/levels.json"

window = SF::RenderWindow.new(SF.video_mode(WIN_WIDTH, WIN_HEIGHT), "Lifish Edit")
font = SF::Font.from_file "#{LIFISH_DIR}/assets/fonts/pf_tempesta_seven.ttf"

lr = LE::LevelRenderer.new ls.next

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
		end
	end
	window.clear
	window.draw lr
	window.display
end
