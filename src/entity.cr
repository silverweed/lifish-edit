require "crsfml/graphics"

module LE

class Entity
	include Utils

	getter sprite

	def initialize(entity_type : Symbol)
		texture_name = entity_type.to_s + ".png"
		@texture = SF::Texture.from_file(get_graphic texture_name)
		@sprite = SF::Sprite.new @texture
	end

	def draw(target, states : SF::RenderStates)
		target.draw(sprite, states)
	end
end

end # module LE
