# Module constants
module LE
	# Level width in tiles
	LV_WIDTH = 15
	# Level height in tiles
	LV_HEIGHT = 13
	# Tile size in pixel
	TILE_SIZE = 32
	# Width of the side left panel, in pixel
	SIDE_PANEL_WIDTH = 240
	# Vertical offset in pixel (i.e. menu height)
	MENU_HEIGHT = 32
	WIN_WIDTH = LV_WIDTH * TILE_SIZE + SIDE_PANEL_WIDTH
	WIN_HEIGHT = LV_HEIGHT * TILE_SIZE + MENU_HEIGHT
end
