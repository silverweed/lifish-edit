# Functions which are only used in the main

class LE::App
	def place_entity
		tile = mouse_utils.get_touched_tile
		if @selected_entity != nil && tile.is_a? Tuple
			history.save
			lr.place_entity(tile, @selected_entity.not_nil!)
		end
	end

	@lvbuf = 0
	@lvbufclock = SF::Clock.new

	def jump_to_lv(n)
		lr.save_level
		if @lvbufclock.elapsed_time > SF.seconds(0.5)
			@lvbuf = n
		else
			@lvbuf = @lvbuf * 10 + n
		end
		@lvbufclock.restart
		lr.level = ls[@lvbuf - 1]
	end

	def highlight_tile(window)
		return if help.active

		touched = mouse_utils.get_touched_tile
		hlrect = SF::RectangleShape.new(SF.vector2f(LE::TILE_SIZE, LE::TILE_SIZE))
		hlrect.fill_color = SF.color(200, 200, 200, 70)
		hlrect.outline_color = SF.color(0, 0, 0, 255)
		hlrect.outline_thickness = 2
		draw = false

		if touched
			x, y = touched.as Tuple(Int32, Int32)
			hlrect.position = SF.vector2f((x + 1) * LE::TILE_SIZE + LE::SIDE_PANEL_WIDTH,
						      (y + 1) * LE::TILE_SIZE + LE::MENU_HEIGHT)
			draw = true
		else
			btn = sidebar.get_touched_button(window.map_pixel_to_coords(SF::Mouse.get_position(window)))
			if btn
				hlrect.position = btn
				hlrect.size = SF.vector2f(1.2 * LE::TILE_SIZE, 1.2 * LE::TILE_SIZE)
				draw = true
			end
		end

		window.draw(hlrect) if draw
	end
end

def keep_ratio(size, designedsize)
	viewport = SF::FloatRect.new(0_f32, 0_f32, 1_f32, 1_f32)
	screenw = size.width / designedsize[0].to_f32
	screenh = size.height / designedsize[1].to_f32

	if screenw > screenh
		viewport.width = screenh / screenw
		viewport.left = (1 - viewport.width) / 2_f32
	elsif screenh > screenw
		viewport.height = screenw / screenh
		viewport.top = (1 - viewport.height) / 2_f32
	end

	view = SF::View.new(SF::FloatRect.new(0_f32, 0_f32, designedsize[0].to_f32, designedsize[1].to_f32))
	view.viewport = viewport
	return view
end
