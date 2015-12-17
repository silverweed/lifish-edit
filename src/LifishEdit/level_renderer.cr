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

	# Applies `@tiles` modifications to current `@level`
	private def save_level
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
		end
	end

	# Loads current `@level` into `@tiles`
	private def load_level
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
				if $verbose
					STDERR.puts "Creating entity #{c}"
				end
				@tiles << LE::Entity.new entity, @level.tileIDs
			end
		end
		bg_texture = SF::Texture.from_file(get_graphic! "bg#{@level.tileIDs["bg"]}.png")
		@bg.texture = bg_texture
		@bg.texture_rect = SF.int_rect 0, 0, LE::TILE_SIZE, LE::TILE_SIZE
	end

	def draw(target, states : SF::RenderStates)
		LV_HEIGHT.times do |row|
			LV_WIDTH.times do |col|
				entity = @tiles[col+LV_WIDTH*row]
				pos = SF.vector2 TILE_SIZE*col, TILE_SIZE*row
				@bg.position = pos + offset
				target.draw @bg
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
end

end # module LE
