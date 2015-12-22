# level.cr - The level representation
require "json"

module LE

# A Lifish level, containing data deserialized from a JSON file.
# Levels are usually created by a `LevelSet`.
class Level
	property time, music, tileIDs, tilemap
	getter orig_tilemap

	# Initializes this level with the parameters given by
	# the hash *json*. May fail if *json* is not a valid hash.
	def initialize(json)
		@time = json["time"] as Int
		@music = json["music"] as Int
		@tileIDs = json["tileIDs"] as Hash
		@orig_tilemap = @tilemap = json["tilemap"] as String
	end

	# Serializes this level into JSON
	def serialize : String
		String.build do |io|
			io.json_object do |obj|
				obj.field "time", @time
				obj.field "music", @music
				obj.field "tileIDs", @tileIDs
				obj.field "tilemap", @tilemap
			end
		end
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
