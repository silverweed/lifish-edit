# level.cr - The level representation
require "./data"
require "./entities.cr"

# A Lifish level, containing data deserialized from a JSON file.
# Levels are usually created by a `LevelSet`.
class LE::Level
	property time, music, tileIDs, tilemap, effects
	getter orig_tilemap, lvnum

	# Initializes this level with the parameters given by
	# the hash *description*.
	def initialize(description : LE::Data::Level, @lvnum : UInt32)
		@time    = description.time.as Int32
		@music   = description.music.as UInt16
		@tileIDs = description.tileIDs.as LE::Data::TileIDs
		@orig_tilemap = @tilemap = description.tilemap.as String
		@orig_tileIDs = @tileIDs
		@effects = description.effects || [] of String
		@width = LE::LV_WIDTH
		@height = LE::LV_HEIGHT
	end

	# Serializes this level into JSON
	def serialize
		{
			time: @time,
			num: @lvnum,
			music: @music,
			tileIDs: @tileIDs,
			tilemap: @tilemap,
			effects: @effects,
			width: @width,
			height: @height
		}
	end

	# Prints a human-readable representation of this level.
	def dump
		puts "Level ##{@lvnum}\n\
			Time: #{@time} s\n\
			Music: #{@music}\n\
			TileIDs: {\n\
			\tborder: #{@tileIDs.border},\n\
			\tbreakable: #{@tileIDs.breakable},\n\
			\tfixed: #{@tileIDs.fixed},\n\
			\tbg: #{@tileIDs.bg}\n\
			},\n\
			Tilemap: #{@tilemap}"
	end

	def restore!
		@tilemap = @orig_tilemap
		@tileIDs = @orig_tileIDs
	end

	def clear!
		@tilemap = "#{LE.get_entity_symbol(:empty)}" * @tilemap.size
	end
end
