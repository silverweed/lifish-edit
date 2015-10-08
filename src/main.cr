# Lifish Edit
# by Giacomo Parolini
#
# main.cr - Application entry point

require "crsfml/graphics"
require "crsfml/window"
require "./*"

WIN_WIDTH = 800
WIN_HEIGHT = 600

ls = LE::LevelSet.new "levels.json"
level = ls[0]
#level.dump if level
#ls.dump
exit 0

window = SF::RenderWindow.new(SF.video_mode(WIN_WIDTH, WIN_HEIGHT), "Lifish Edit")

while window.open?
	while event = window.poll_event
		case event.type
		when SF::Event::Closed
			window.close
		end
	end
	window.clear
	window.display
end
