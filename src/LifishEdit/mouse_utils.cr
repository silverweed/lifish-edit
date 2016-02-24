require "./consts"
require "crsfml/window_obj"

module LE

# MouseUtils provides utility methods for the mouse within a `SF::RenderWindow`.
class MouseUtils
	def initialize(@window : SF::RenderWindow, @lr : LE::LevelRenderer, @menu : LE::Menu)
	end

	def get_touched : (Entity|MenuCallback)?
		x, y = SF::Mouse.get_position @window
		if x > LE::SIDE_PANEL_WIDTH && y > LE::MENU_HEIGHT
			get_touched_entity
		elsif y <= LE::MENU_HEIGHT
			@menu.touch SF.vector2f x, y
		else
			nil
		end
	end

	def get_touched_entity : Entity?
		@lr.tiles.each do |tile|
			if tile.is_a? Entity && tile.contains?(SF::Mouse.get_position @window)
				# Since tiles are guaranteed to be non-overlapping,
				# we can return here.
				return tile
			end
		end
		nil
	end
end

end # module LE
