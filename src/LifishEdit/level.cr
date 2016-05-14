# level.cr - The level representation
require "./data"

module LE

# A Lifish level, containing data deserialized from a JSON file.
# Levels are usually created by a `LevelSet`.
class Level
	property time, music, tileIDs, tilemap
	getter orig_tilemap, lvnum

	# Initializes this level with the parameters given by
	# the hash *description*. 
	def initialize(description : LE::Data::Level, @lvnum : UInt32)
		@time    = description.time as Int32
		@music   = description.music as UInt16
		@tileIDs = description.tileIDs as LE::Data::TileIDs 
		@orig_tilemap = @tilemap = description.tilemap as String
	end

	# Serializes this level into JSON
	def serialize
		{
			"time" => @time,
			"music" => @music,
			"tileIDs" => @tileIDs,
			"tilemap" => @tilemap
		}
	end

	# Prints a human-readable representation of this level.
	def dump
		puts "Time: #{@time} s\n\
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
	end
end

end # module LE
