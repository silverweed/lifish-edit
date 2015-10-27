require "crsfml/graphics"
require "crsfml/system"
require "./utils.cr"

module LE

class LevelRenderer
	include Utils

	getter level

	def initialize(@level)
		@tiles = [] of Entity?
		@bg = SF::Sprite.new
		load_level
	end

	def level=(@level)
		load_level
	end

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
				pos = SF.vector2f(TILE_SIZE*col, TILE_SIZE*row)
				@bg.position = pos
				target.draw @bg
				if entity
					entity.position = pos
					target.draw entity
				end
			end
		end
	end
end

end # module LE
