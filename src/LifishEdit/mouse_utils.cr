require "./consts"
require "crsfml/window"

module LE

# MouseUtils provides utility methods for the mouse within a `SF::RenderWindow`.
class MouseUtils
	def initialize(@app : LE::App)
	end

	def get_touched : (LE::Entity|MenuCallback)?
		x, y = @app.window.map_pixel_to_coords(SF::Mouse.get_position(@app.window))

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
	def get_touched_tile : Tuple(Int32, Int32)?
		x, y = @app.window.map_pixel_to_coords(SF::Mouse.get_position(@app.window))
		
		STDERR.puts "#{x}, #{y}"
		# Get tile index from mouse position
		tx = ((x.to_f32 - LE::SIDE_PANEL_WIDTH - LE::TILE_SIZE) / LE::TILE_SIZE).floor.to_i32
		return nil if tx < 0 || tx >= LE::LV_WIDTH

		ty = ((y.to_f32 - LE::MENU_HEIGHT - LE::TILE_SIZE) / LE::TILE_SIZE).floor.to_i32
		return nil if ty < 0 || ty >= LE::LV_HEIGHT

		{tx, ty}
	end
end

end # module LE
