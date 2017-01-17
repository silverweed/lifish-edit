require "./consts"
require "./utils"
require "./data"
require "crsfml/graphics"

module LE

# An Entity is essentially a sprite whose texture depends
# on its type (as defined in `ENTITIES`).
class Entity
	include LE::Utils

	getter sprite, type, button_sprite

	# Creates an Entity of type `@type`. If the entity is a wall,
	# a `tileIDs` hash needs to be given to specify the tileset used.
	def initialize(@app : LE::App, @type : Symbol,
		       tileIDs : LE::Data::TileIDs = LE::Data::TileIDs.new(fixed: 1_u16, breakable: 1_u16))

		@sprite = SF::Sprite.new
		# The sprite drawn on side panel buttons
		@button_sprite = SF::Sprite.new
		# These are visual helpers for entities bigger than 1 tile
		@pivot_sprite = SF::Sprite.new
		@bounding_rect = SF::RectangleShape.new(SF.vector2f(0, 0))

		unless @type == :empty
			texture_name = @type.to_s + ".png"
			begin
				texture = @app.cache.texture(texture_name)
			rescue
			end
		end
		if texture.is_a? SF::Texture
			@texture = texture
			@sprite.texture = @texture
			@button_sprite.texture = @texture
		else
			@texture = SF::Texture.new(TILE_SIZE, TILE_SIZE)
		end
		
		sx, sy = LE.get_entity_size(@type)
		rect = SF.int_rect(0, 0, sx * TILE_SIZE, sy * TILE_SIZE)

		case @type
		when :fixed
			rect.left = TILE_SIZE * (tileIDs.fixed.to_i64 - 1)
		when :breakable
			rect.top = TILE_SIZE * (tileIDs.breakable.to_i64 - 1)
		end

		@sprite.texture_rect = rect
		@button_sprite.texture_rect = rect

		# Handle entities bigger than 1x1 tile
		if sx != 1 || sy != 1
			pivot_texture = @app.cache.texture(LE::Utils.get_resource("pivot.png"))
			if pivot_texture.is_a? SF::Texture
				@pivot_sprite.texture = pivot_texture
				@pivot_sprite.texture_rect = SF.int_rect(0, 0, TILE_SIZE, TILE_SIZE)
			end
			
			@bounding_rect.size = SF.vector2f(sx * TILE_SIZE, sy * TILE_SIZE)
			@bounding_rect.fill_color = SF::Color.new(0, 0, 150, 80)
			@bounding_rect.outline_color = SF::Color::Blue
			@bounding_rect.outline_thickness = 0
			@button_sprite.scale = SF.vector2f(1_f32 / sx, 1_f32 / sy)
		end
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(@sprite, states)
		target.draw(@bounding_rect, states)
		target.draw(@pivot_sprite, states)
	end

	def position=(pos)
		@sprite.position = pos
		@pivot_sprite.position = pos
		@bounding_rect.position = pos
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
