require "./utils"
require "crsfml/graphics"
require "crsfml/system"

module LE

# A LevelRenderer manages and draws a `Level` with its entities.
class LevelRenderer
	getter level, tiles
	getter offset

	@bg_texture : SF::Texture?
	@border_texture : SF::Texture?

	def initialize(@app : LE::App, @level : LE::Level)
		@tiles = [] of LE::Entity?
		@bg = SF::Sprite.new
		@bg.position = SF.vector2f(LE::SIDE_PANEL_WIDTH + LE::TILE_SIZE, 
					   LE::MENU_HEIGHT + LE::TILE_SIZE)
		@border = SF::Sprite.new
		@border.position = SF.vector2f(LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT)

		@offset = SF.vector2f(0_f32 + LE::TILE_SIZE, 0_f32 + LE::TILE_SIZE)
		@level_text = SF::Text.new("#{@level.lvnum}", @app.font, 20)
		@level_text.position = SF.vector2f(LE::SIDE_PANEL_WIDTH + LE::TILE_SIZE * (LE::LV_WIDTH + 1), 
						   LE::MENU_HEIGHT)
		@level_text.color = SF::Color::White
		@level_text.style = SF::Text::Bold
		@level_text_shadow = SF::Text.new(@level_text.string, @level_text.font.not_nil!,
						  @level_text.character_size)
		@level_text_shadow.position = @level_text.position + SF.vector2f(2, 2)
		@level_text_shadow.style = SF::Text::Bold 
		@level_text_shadow.color = SF::Color::Black 
	end

	def level=(lv)
		@level = lv
		load_level
		@app.sidebar.refresh
	end

	def offset=(o)
		@offset = SF.vector2f(LE::TILE_SIZE + o.x, LE::TILE_SIZE + o.y)
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		# Background
		target.draw(@bg, states)
	
		# Borders
		target.draw(@border, states)

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

		STDERR.puts("Tilemap now: #{@level.tilemap}") if @app.verbose?
		
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
			@bg.texture = @bg_texture.not_nil!
			@bg.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE * LE::LV_WIDTH,
						       LE::TILE_SIZE * LE::LV_HEIGHT)
			@bg.texture.not_nil!.repeated = true

			@border_texture = @app.cache.texture("border#{@level.tileIDs.border}.png")
			@border.texture = @border_texture.not_nil!
			@border.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE * (LE::LV_WIDTH + 2),
							   LE::TILE_SIZE * (LE::LV_HEIGHT + 2))
		rescue ex
			STDERR.puts(ex)
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
		unless @tiles[idx].is_a?(LE::Entity) && @tiles[idx].not_nil!.type == entity.type
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
