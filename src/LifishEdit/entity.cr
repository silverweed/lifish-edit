require "./consts"
require "./utils"
require "crsfml/graphics"

module LE

# An Entity is essentially a sprite whose texture depends
# on its type (as defined in `ENTITIES`).
class Entity
	include LE::Utils

	getter sprite, type

	# Creates an Entity of type `@type`. If the entity is a wall,
	# a `tileIDs` hash needs to be given to specify the tileset used.
	def initialize(@app, @type : Symbol, tileIDs = { "fixed" => 1_i64, "breakable" => 1_i64 })
		texture_name = @type.to_s + ".png"
		@sprite = SF::Sprite.new
		begin
			@texture = SF::Texture.from_file(get_graphic(texture_name))
			@sprite.texture = @texture as SF::Texture if @texture
		rescue
		end
		rect = SF.int_rect 0, 0, TILE_SIZE, TILE_SIZE
		case @type
		when :fixed
			rect.left = TILE_SIZE * (tileIDs["fixed"] as Int64 - 1)
		when :breakable
			rect.top = TILE_SIZE * (tileIDs["breakable"] as Int64 - 1)
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
