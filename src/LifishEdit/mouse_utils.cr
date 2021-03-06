require "crsfml/window"
require "./consts"

# MouseUtils provides utility methods for the mouse within a `SF::RenderWindow`.
class LE::MouseUtils
	def initialize(@app : LE::App)
	end

	macro get_mouse_xy
		@app.window.map_pixel_to_coords(SF::Mouse.get_position(@app.window))
	end

	# Returns whichever object the mouse is currently hovering on.
	# That may be either an Entity (if the mouse is over the level),
	# a MenuCallback (if it's over the menu), or nil.
	def touch : (LE::Entity|MenuCallback)?
		x, y = get_mouse_xy
		mpos = SF.vector2f(x, y)

		if @app.quit_prompt.active
			@app.quit_prompt.touch(mpos)
			return nil
		end

		if y <= LE::MENU_HEIGHT
			return @app.menu.touch(mpos)
		elsif x < LE::SIDE_PANEL_WIDTH
			e = @app.sidebar.touch(mpos)
			@app.selected_entity = e if e != nil
			return
		else
			return get_touched_entity
		end
	end

	# Returns :back, :fw or nil depending of which the mouse is hovering.
	def get_touching_time_tweaker : Symbol?
		x, y = get_mouse_xy
		case @app.sidebar.get_touched_button(SF.vector2f(x, y))
		when @app.sidebar.time_tweaker.back_button
			return :back
		when @app.sidebar.time_tweaker.fw_button 
			return :fw
		end
		nil
	end

	# If the mouse is on the level, return the entity it's hovering on (or nil)
	def get_touched_entity : LE::Entity?
		tile = get_touched_tile
		return nil unless tile.is_a? Tuple

		@app.lr.tiles[LE::Utils.tile_to_idx(tile)]
	end

	# Gets tile index from mouse position
	def get_touched_tile : Tuple(Int32, Int32)?
		x, y = get_mouse_xy
		
		# Get tile index from mouse position
		tx = ((x.to_f32 - LE::SIDE_PANEL_WIDTH - LE::TILE_SIZE) / LE::TILE_SIZE).floor.to_i32
		return nil if tx < 0 || tx >= LE::LV_WIDTH

		ty = ((y.to_f32 - LE::MENU_HEIGHT - LE::TILE_SIZE) / LE::TILE_SIZE).floor.to_i32
		return nil if ty < 0 || ty >= LE::LV_HEIGHT

		{tx, ty}
	end
end
