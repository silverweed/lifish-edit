require "crsfml/graphics"
require "crsfml/system"
require "./utils.cr"

module LE

class LevelRenderer
	include Utils

	getter level, tiles

	def initialize(@level)
		@tiles = [] of Entity?
		@bg = SF::Sprite.new
		load_level
	end

	def level=(lv)
		save_level
		@level = lv
		load_level
	end

	# Applies tiles modifications to current `@level`
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

	# Loads current `@level`
	private def load_level
		@tiles = [] of Entity?
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
				@tiles << Entity.new entity, @level.tileIDs
			end
		end
		bg_texture = SF::Texture.from_file(get_graphic "bg#{@level.tileIDs["bg"]}.png")
		@bg.texture = bg_texture
		@bg.texture_rect = SF.int_rect 0, 0, TILE_SIZE, TILE_SIZE
	end

	def draw(target, states : SF::RenderStates)
		LV_HEIGHT.times do |row|
			LV_WIDTH.times do |col|
				entity = @tiles[col+LV_WIDTH*row]
				pos = SF.vector2f TILE_SIZE*col, TILE_SIZE*row
				@bg.position = pos
				target.draw @bg
				if entity
					entity.position = pos
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