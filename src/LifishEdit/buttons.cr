require "crsfml/graphics"

module LE

class Button
	property selected

	def initialize
		@bg_rect = SF::RectangleShape.new(SF.vector2f(LE::BUTTONS_WIDTH, LE::BUTTONS_WIDTH))
		@bg_rect.fill_color = SF.color(0, 0, 255, 150)
		@bg_rect.outline_thickness = 1
		@bg_rect.outline_color = SF.color(50, 50, 50, 255)
		@selected = false
	end

	def global_bounds
		@bg_rect.global_bounds
	end

	def local_bounds
		@bg_rect.local_bounds
	end

	def position
		@bg_rect.position
	end

	def position=(pos)
		@bg_rect.position = pos
	end

	def contains?(pos)
		@bg_rect.global_bounds.contains?(pos)
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		if @selected
			@bg_rect.fill_color = SF.color(0, 0, 255, 150)
		else
			@bg_rect.fill_color = SF.color(0, 0, 0, 0)
		end
		target.draw(@bg_rect, states)
	end
end

class TextButton < Button
	getter callback

	def initialize(font, @callback : -> Void, string = "", width = 0, height = 0)
		super()
		@text = SF::Text.new(string, font, 14)
		@text.color = SF::Color::Black
		b = @text.local_bounds
		@bg_rect.size = SF.vector2f([width, b.width + 4].max, [height, b.height + 4].max)
		center_text
		@bg_rect.fill_color = SF::Color.new(207, 210, 218)
	end

	def fill_color=(col)
		@bg_rect.fill_color = col
	end

	def color=(col)
		@text.color = col
	end
	
	def string=(s)
		@text.string = s
		center_text
	end

	private def center_text
		tb = @text.local_bounds
		rb = @bg_rect.size
		@text.position = @bg_rect.position + SF.vector2f((rb.x - tb.width) / 2, (rb.y - tb.height) / 2)
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@bg_rect, states)
		target.draw(@text, states)
	end

	def position=(pos)
		super
		b = @text.local_bounds
		bs = @bg_rect.size
		@text.position = @bg_rect.position + SF.vector2f((bs.x - b.width) / 2, (bs.y - b.height) / 2)
	end
end

class EntityButton < Button
	getter entity

	def initialize(@app : LE::App, entity_sym)
		super()
		@entity = LE::Entity.new(@app, entity_sym, 
					 LE::Data::TileIDs.new(breakable: 1_u16, fixed: 1_u16))
	end

	def draw(target, states : SF::RenderStates)
		super
		target.draw(@entity.button_sprite, states)
	end

	def position=(pos)
		super
		@entity.button_sprite.position = SF.vector2f(
			pos.x + 0.1 * LE::TILE_SIZE,
			pos.y + 0.1 * LE::TILE_SIZE)
	end
end

class CallbackButton < Button
	getter callback
	getter id

	def initialize(@app : LE::App, @callback : -> Void, @id : Int32)
		super()
		@bg_rect.fill_color = SF.color(0, 0, 0, 0)
		@sprite = SF::Sprite.new
	end

	def draw(target, states : SF::RenderStates)
		super
		target.draw(@sprite, states)
	end

	def position=(pos)
		super
		@sprite.position = SF.vector2f(pos.x + 0.1 * LE::TILE_SIZE, pos.y + 0.1 * LE::TILE_SIZE)
	end
end

class BgBorderWallButton < CallbackButton
	def initialize(app : LE::App, callback : -> Void, type, id)
		super(app, callback, id)
		if {:bg, :border}.includes?(type)
			@sprite.texture = @app.cache.texture("#{type}#{id}.png").as SF::Texture
		else
			@sprite.texture = @app.cache.texture("#{type}.png").as SF::Texture
		end
		@sprite.texture_rect = SF.int_rect(type == :fixed ? (id-1) * LE::TILE_SIZE : 0,
						type == :bg || type == :fixed ?
							0
							: (id-1) * LE::TILE_SIZE,
						LE::TILE_SIZE, LE::TILE_SIZE)
	end
end

class EffectButton < CallbackButton
	def initialize(app : LE::App, callback : -> Void, id)
		super
		@sprite.texture =
			if LE::EFFECTS[id][1] != nil
				@app.cache.texture(LE::Utils.get_resource(LE::EFFECTS[id][1].not_nil!))
			else
				
				@app.cache.texture(LE::Utils.get_resource("white.png"))
			end.as SF::Texture
		@sprite.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE, LE::TILE_SIZE)
		case id
		when 1
			@sprite.color = SF::Color::Black
		end
	end
end

class SymmetryButton < CallbackButton
	def initialize(app : LE::App, callback : -> Void, id)
		super
		@sprite.texture = @app.cache.texture(LE::Utils.get_resource(LE::SYMMETRIES[id][1])).as SF::Texture
		@sprite.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE, LE::TILE_SIZE)
	end
end

end # module LE
