require "crsfml/window_obj"

module LE

class MouseUtils
	def initialize(@window : SF::RenderWindow, @lr : LE::LevelRenderer)
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
