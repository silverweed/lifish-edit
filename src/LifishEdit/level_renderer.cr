require "./utils"
require "crsfml/graphics"
require "crsfml/system"

module LE

# A LevelRenderer manages and draws a `Level` with its entities.
class LevelRenderer
	include LE::Utils

	getter level, tiles
	property offset

	def initialize(@level)
		@tiles = [] of Entity?
		@bg = SF::Sprite.new
		@offset = SF.vector2 0, 0
		load_level
	end

	def level=(lv)
		save_level
		@level = lv
		load_level
	end

	def draw(target, states : SF::RenderStates)
		@bg.position = SF.vector2f LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT
		target.draw @bg
		LE::LV_HEIGHT.times do |row|
			LE::LV_WIDTH.times do |col|
				entity = @tiles[col+LE::LV_WIDTH*row]
				pos = SF.vector2 LE::TILE_SIZE*col, LE::TILE_SIZE*row
				if entity
					entity.position = pos + offset
					target.draw entity
				end
			end
		end
	end

	def remove_entity!(entity : LE::Entity)
		@tiles.map! { |tile| tile == entity ? nil : tile }
	end

	# Applies `@tiles` modifications to current `@level`
	def save_level
		tilemap = ""
		@tiles.each do |tile|
			if tile
				tilemap += "#{LE.get_entity_symbol tile.type}"
			else
				tilemap += "0"
			end
		end
		if tilemap.size == @level.tilemap.size
			@level.tilemap = tilemap
		else
			STDERR.puts "tilemap.size = #{tilemap.size} versus #{@level.tilemap.size}!"
		end
	end

	# Loads current `@level` into `@tiles`
	def load_level
		@tiles = [] of LE::Entity?
		@level.tilemap.each_char do |c|
			break if c == '\0'
			case entity = LE.get_entity c
			when :unknown
				STDERR.puts "Invalid tile for level: #{c}. Setting tile to empty."
				@tiles << nil
			when :empty
				@tiles << nil
			else
				@tiles << LE::Entity.new entity, @level.tileIDs
			end
		end
		unless @tiles.size == @level.tilemap.size
			raise "Invalid number of tiles! (#{@tiles.size} instead of #{@level.tilemap.size})"
		end
		bg_texture = SF::Texture.from_file(get_graphic! "bg#{@level.tileIDs["bg"]}.png")
		@bg.texture = bg_texture
		@bg.texture_rect = SF.int_rect 0, 0, LE::TILE_SIZE *
			LE::LV_WIDTH, LE::TILE_SIZE * LE::LV_HEIGHT
		if @bg.texture.is_a? SF::Texture
			(@bg.texture as SF::Texture).repeated = true
		end
	end
end

end # module LE
