require "crsfml/graphics"
require "./consts"

module LE

class Entity
	include Utils

	getter sprite

	def initialize(entity_type : Symbol)
		texture_name = entity_type.to_s + ".png"
		@texture = SF::Texture.from_file(get_graphic texture_name)
		@sprite = SF::Sprite.new @texture
		@sprite.texture_rect = SF.int_rect 0, 0, TILE_SIZE, TILE_SIZE
	end

	def draw(target, states : SF::RenderStates)
		target.draw sprite, states
	end

	def position=(pos)
		@sprite.position = pos
	end

	def position()
		@sprite.position
	end
end

end # module LE
