require "./consts"
require "crsfml/window_obj"

module LE

# MouseUtils provides utility methods for the mouse within a `SF::RenderWindow`.
class MouseUtils
	def initialize(@app : LE::App)
	end

	def get_touched : (LE::Entity|MenuCallback)?
		x, y = SF::Mouse.get_position(@app.window)

		if y <= LE::MENU_HEIGHT
			@app.menu.touch(SF.vector2f(x, y))
		elsif x < LE::SIDE_PANEL_WIDTH
			@app.selected_entity = @app.sidebar.touch(SF.vector2f(x, y))
			nil
		else
			get_touched_entity
		end
	end

	def get_touched_entity : LE::Entity?
		tile = get_touched_tile
		return nil unless tile.is_a? Tuple

		@app.lr.tiles[LE::Utils.tile_to_idx(tile)]
	end

	# Gets tile index from mouse position
	def get_touched_tile
		x, y = SF::Mouse.get_position(@app.window)

		# Get tile index from mouse position
		tx = (x - LE::SIDE_PANEL_WIDTH) / LE::TILE_SIZE
		return nil if tx < 0 || tx >= LE::LV_WIDTH

		ty = (y - LE::MENU_HEIGHT) / LE::TILE_SIZE
		return nil if ty < 0 || ty >= LE::LV_HEIGHT

		{tx, ty}
	end
end

end # module LE
