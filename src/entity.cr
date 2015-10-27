require "crsfml/graphics"
require "./consts"

module LE

class Entity
	include Utils

	getter sprite

	def initialize(entity_type : Symbol, tileIDs = nil : Hash?)
		texture_name = entity_type.to_s + ".png"
		@sprite = SF::Sprite.new
		begin
			@texture = SF::Texture.from_file(get_graphic texture_name)
			@sprite.texture = @texture
		rescue
		end
		rect = SF.int_rect 0, 0, TILE_SIZE, TILE_SIZE
		case entity_type
		when :fixed
			rect.left = TILE_SIZE * (tileIDs["fixed"] as Int - 1)
		when :breakable
			rect.top = TILE_SIZE * (tileIDs["breakable"] as Int - 1)
		end
		@sprite.texture_rect = rect
	end

	def draw(target, states : SF::RenderStates)
		target.draw sprite, states
	end

	def position=(pos)
		@sprite.position = pos
	end

	def position
		@sprite.position
	end
end

end # module LE
