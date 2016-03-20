# level.cr - The level representation
require "json"

module LE

# A Lifish level, containing data deserialized from a JSON file.
# Levels are usually created by a `LevelSet`.
class Level
	property time, music, tileIDs, tilemap
	getter orig_tilemap, lvnum

	# Initializes this level with the parameters given by
	# the hash *json*. May fail if *json* is not a valid hash.
	def initialize(json, @lvnum)
		@time = json["time"].as_i
		@music = json["music"].as_i
		@tileIDs = json["tileIDs"].as_h
		@orig_tilemap = @tilemap = json["tilemap"].as_s
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
			\tborder: #{@tileIDs["border"]},\n\
			\tbreakable: #{@tileIDs["breakable"]},\n\
			\tfixed: #{@tileIDs["fixed"]},\n\
			\tbg: #{@tileIDs["bg"]}\n\
			},\n\
			Tilemap: #{@tilemap}"
	end

	def restore!
		@tilemap = @orig_tilemap
	end
end

end # module LE
