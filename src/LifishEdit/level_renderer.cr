require "./utils"
require "crsfml/graphics"
require "crsfml/system"

module LE

# A LevelRenderer manages and draws a `Level` with its entities.
class LevelRenderer
	getter level, tiles
	property offset

	def initialize(@app : LE::App, @level : LE::Level)
		@tiles = [] of LE::Entity?
		@bg = SF::Sprite.new
		@bg.position = SF.vector2f(LE::SIDE_PANEL_WIDTH, LE::MENU_HEIGHT)
		@bg_texture = nil as SF::Texture?
		@offset = SF.vector2(0_f32, 0_f32) as SF::Vector2(Float32)
		@level_text = SF::Text.new("#{@level.lvnum}", @app.font, 18)
		@level_text.position = SF.vector2f(5, LE::WIN_HEIGHT - 23)
		@level_text.color = SF::Color::Black
		@level_text.style = SF::Text::Bold
		load_level
	end

	def level=(lv)
		@level = lv
		load_level
	end

	def draw(target, states : SF::RenderStates)
		target.draw(@bg)
		LE::LV_HEIGHT.times do |row|
			LE::LV_WIDTH.times do |col|
				entity = @tiles[col+LE::LV_WIDTH*row]
				pos = SF.vector2(LE::TILE_SIZE*col, LE::TILE_SIZE*row)
				if entity
					entity.position = pos + @offset
					target.draw(entity)
				end
			end
		end
		target.draw(@level_text)
	end

	def remove_entity!(entity : LE::Entity)
		@tiles.map! { |tile| tile == entity ? nil : tile }
	end

	def place_entity!(tile, entity : LE::Entity)
		return unless tile.is_a? Tuple
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
			STDERR.puts "tilemap.size = #{tilemap.size} versus #{@level.tilemap.size}!"
		end
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
		begin
			@bg_texture = SF::Texture.from_file(LE::Utils.get_graphic("bg#{@level.tileIDs.bg}.png"))
			@bg.texture = @bg_texture as SF::Texture
			@bg.texture_rect = SF.int_rect(0, 0, LE::TILE_SIZE * LE::LV_WIDTH,
						       LE::TILE_SIZE * LE::LV_HEIGHT)
			(@bg.texture as SF::Texture).repeated = true
		rescue
		end
		@level_text.string = "#{@level.lvnum}"
	end
end

end # module LE
