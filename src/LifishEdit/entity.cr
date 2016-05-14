require "./consts"
require "./utils"
require "./data"
require "crsfml/graphics"

module LE

# An Entity is essentially a sprite whose texture depends
# on its type (as defined in `ENTITIES`).
class Entity
	include LE::Utils

	getter sprite, type

	# Creates an Entity of type `@type`. If the entity is a wall,
	# a `tileIDs` hash needs to be given to specify the tileset used.
	def initialize(@app : LE::App, @type : Symbol,
		       tileIDs : LE::Data::TileIDs = LE::Data::TileIDs.new(fixed: 1_u16, breakable: 1_u16))

		@sprite = SF::Sprite.new

		unless @type == :empty
			texture_name = @type.to_s + ".png"
			begin
				texture = SF::Texture.from_file(get_graphic(texture_name)) 
			rescue
			end
		end
		if texture.is_a? SF::Texture
			@texture = texture as SF::Texture
			@sprite.texture = @texture 
		else
			@texture = SF::Texture.new(0, 0)
		end
		
		rect = SF.int_rect(0, 0, TILE_SIZE, TILE_SIZE)
		case @type
		when :fixed
			rect.left = TILE_SIZE * (tileIDs.fixed.to_i64 - 1)
		when :breakable
			rect.top = TILE_SIZE * (tileIDs.breakable.to_i64 - 1)
		end
		@sprite.texture_rect = rect
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@sprite, states)
	end

	def position=(pos)
		@sprite.position = pos
	end

	def position
		@sprite.position
	end

	def contains?(point)
		@sprite.position.x <= point.x && 
			point.x <= @sprite.position.x + @sprite.texture_rect.width &&
			@sprite.position.y <= point.y &&
			point.y <= @sprite.position.y + @sprite.texture_rect.height
	end
end

end # module LE
