require "./utils"
require "crsfml/graphics"
require "crsfml/system"

module LE

# A LevelRenderer manages and draws a `Level` with its entities.
class LevelRenderer
	getter level, tiles
	getter offset

	def initialize(@app : LE::App, @level : LE::Level)
		@tiles = [] of LE::Entity?
		@bg = SF::Sprite.new
		@bg.position = SF.vector2f(LE::SIDE_PANEL_WIDTH + LE::TILE_SIZE, 
					   LE::MENU_HEIGHT + LE::TILE_SIZE)
		@bg_texture = nil as SF::Texture?
		@border_texture = nil as SF::Texture?
		@borders = {
			    :upper => SF::Sprite.new,
			    :upper_left => SF::Sprite.new,
			    :upper_right => SF::Sprite.new,
			    :left => SF::Sprite.new,
			    :right => SF::Sprite.new,
			    :lower => SF::Sprite.new,
			    :lower_left => SF::Sprite.new,
			    :lower_right => SF::Sprite.new,
		}

		@offset = SF.vector2f(0_f32 + LE::TILE_SIZE, 0_f32 + LE::TILE_SIZE)
		@level_text = SF::Text.new("#{@level.lvnum}", @app.font, 20)
		@level_text.position = SF.vector2f(LE::SIDE_PANEL_WIDTH + LE::TILE_SIZE * (LE::LV_WIDTH + 1), 
						   LE::MENU_HEIGHT)
		@level_text.color = SF::Color::White
		@level_text.style = SF::Text::Bold
		@level_text_shadow = SF::Text.new(@level_text.string, @level_text.font as SF::Font,
						  @level_text.character_size)
		@level_text_shadow.position = @level_text.position + SF.vector2f(2, 2)
		@level_text_shadow.style = SF::Text::Bold 
		@level_text_shadow.color = SF::Color::Black 
	end

	def level=(lv)
		@level = lv
		load_level
		@app.sidebar.refresh_selected
	end

	def offset=(o)
		@offset = SF.vector2f(LE::TILE_SIZE + o.x, LE::TILE_SIZE + o.y)
	end

	def draw(target, states : SF::RenderStates)
		# Background
		target.draw(@bg, states)
	
		# Borders
		(1..LE::LV_WIDTH + 1).each do |t|
			@borders[:upper].position = SF.vector2f(LE::SIDE_PANEL_WIDTH + t * LE::TILE_SIZE,
								LE::MENU_HEIGHT)
			target.draw(@borders[:upper], states)
			@borders[:lower].position = SF.vector2f(LE::SIDE_PANEL_WIDTH + t * LE::TILE_SIZE,
								LE::MENU_HEIGHT + (LE::LV_HEIGHT + 1) * LE::TILE_SIZE)
			target.draw(@borders[:lower], states)
		end
		(1..LE::LV_HEIGHT + 1).each do |t|
			@borders[:left].position = SF.vector2f(LE::SIDE_PANEL_WIDTH,
								LE::MENU_HEIGHT + t * LE::TILE_SIZE)
			target.draw(@borders[:left], states)
			@borders[:right].position = SF.vector2f(LE::SIDE_PANEL_WIDTH + (LE::LV_WIDTH + 1) *  LE::TILE_SIZE,
								LE::MENU_HEIGHT + t * LE::TILE_SIZE)
			target.draw(@borders[:right], states)
		end
		@borders[:upper_left].position = SF.vector2f(LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT)
		target.draw(@borders[:upper_left], states)
		@borders[:upper_right].position = SF.vector2f(LE::SIDE_PANEL_WIDTH + (LE::LV_WIDTH + 1) * LE::TILE_SIZE,
							      LE::MENU_HEIGHT)
		target.draw(@borders[:upper_right], states)
		@borders[:lower_left].position = SF.vector2f(LE::SIDE_PANEL_WIDTH, 
							     LE::MENU_HEIGHT + (LE::LV_HEIGHT + 1) * LE::TILE_SIZE)
		target.draw(@borders[:lower_left], states)
		@borders[:lower_right].position = SF.vector2f(LE::SIDE_PANEL_WIDTH + (LE::LV_WIDTH + 1) * LE::TILE_SIZE,
							      LE::MENU_HEIGHT + (LE::LV_HEIGHT + 1) * LE::TILE_SIZE)
		target.draw(@borders[:lower_right], states)

		# Entities
		LE::LV_HEIGHT.times do |row|
			LE::LV_WIDTH.times do |col|
				entity = @tiles[col+LE::LV_WIDTH*row]
				pos = SF.vector2(LE::TILE_SIZE*col, LE::TILE_SIZE*row)
				if entity
					entity.position = pos + @offset
					target.draw(entity, states)
				end
			end
		end

		# Level text
		target.draw(@level_text_shadow, states)
		target.draw(@level_text, states)
	end

	# Applies `@tiles` modifications to current `@level`
	def save_level
		tilemap = ""
		@tiles.each do |tile|
			if tile
				tilemap += "#{LE.get_entity_symbol(tile.type)}"
			else
				tilemap += "0"
			end
		end
		if tilemap.size == @level.tilemap.size
			@level.tilemap = tilemap
		else
			raise "tilemap.size = #{tilemap.size} versus #{@level.tilemap.size}!"
		end
		
		@app.ls.data.levels[@level.lvnum - 1] = LE::Data::Level.from_json(
			@level.serialize.to_json)
	end

	# Loads current `@level` into `@tiles`
	def load_level
		@tiles = [] of LE::Entity?
		@level.tilemap.each_char do |c|
			break if c == '\0'
			case entity = LE.get_entity(c)
			when :unknown
				STDERR.puts "Invalid tile for level: #{c}. Setting tile to empty."
				@tiles << nil
			when :empty
				@tiles << nil
			else
				@tiles << LE::Entity.new(@app, entity, @level.tileIDs)
			end
		end
		unless @tiles.size == @level.tilemap.size
			raise "Invalid number of tiles! (#{@tiles.size} instead of #{@level.tilemap.size})"
		end
		# Load background and border textures
		begin
			@bg_texture = @app.cache.texture("bg#{@level.tileIDs.bg}.png")
			@bg.texture = @bg_texture as SF::Texture
			@bg.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE * LE::LV_WIDTH,
						       LE::TILE_SIZE * LE::LV_HEIGHT)
			(@bg.texture as SF::Texture).repeated = true

			@border_texture = @app.cache.texture("border.png")
			@borders.each_value { |b| b.texture = @border_texture as SF::Texture }
			b = (@level.tileIDs.border - 1) * LE::TILE_SIZE
			@borders[:upper].texture_rect = SF.int_rect(0, b, LE::TILE_SIZE, LE::TILE_SIZE)
			@borders[:lower].texture_rect = SF.int_rect(0, b + LE::TILE_SIZE, 
								    LE::TILE_SIZE, -LE::TILE_SIZE)
			@borders[:left].texture_rect = SF.int_rect(LE::TILE_SIZE,
								   b, LE::TILE_SIZE, LE::TILE_SIZE)
			@borders[:right].texture_rect = SF.int_rect(2 * LE::TILE_SIZE,
								   b, -LE::TILE_SIZE, LE::TILE_SIZE)
			@borders[:upper_left].texture_rect = SF.int_rect(2 * LE::TILE_SIZE,
									 b, LE::TILE_SIZE, LE::TILE_SIZE)
			@borders[:lower_left].texture_rect = SF.int_rect(2 * LE::TILE_SIZE,
									 b + LE::TILE_SIZE,
									 LE::TILE_SIZE, -LE::TILE_SIZE)
			@borders[:lower_right].texture_rect = SF.int_rect(3 * LE::TILE_SIZE,
									  b + LE::TILE_SIZE,
									  -LE::TILE_SIZE, -LE::TILE_SIZE)
			@borders[:upper_right].texture_rect = SF.int_rect(3 * LE::TILE_SIZE,
									  b,
									  -LE::TILE_SIZE, LE::TILE_SIZE)
		rescue
		end
		@level_text.string = "#{@level.lvnum}"
		@level_text_shadow.string = @level_text.string
	end

	def remove_entity(entity : LE::Entity)
		@tiles.map! { |tile| tile == entity ? nil : tile }
	end

	def place_entity(tile : Tuple, entity : LE::Entity)
		tx, ty = tile 
		if tx < 0 || ty < 0 || tx >= LE::LV_WIDTH || ty >= LE::LV_HEIGHT
			STDERR.puts "Attempted to place entity in tile #{tile}!"
			return
		end
		idx = LE::Utils.tile_to_idx(tile)
		unless @tiles[idx].is_a?(LE::Entity) && (@tiles[idx] as LE::Entity).type == entity.type
			@tiles[idx] = LE::Entity.new(@app, entity.type)
		end
	end

	{% for name in %w(bg border fixed breakable) %}
		def set_{{name.id}}(id : UInt16)
			@level.tileIDs.{{name.id}} = id
			load_level
		end
	{% end %}
end

end # module LE
