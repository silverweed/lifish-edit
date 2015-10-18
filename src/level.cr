# level.cr - The level representation

module LE

# A Lifish level, containing data deserialized from a JSON file.
# Levels are usually created by a `LevelSet`.
class Level
	property time, music, tileIDs, tilemap

	# Initializes this level with the parameters given by
	# the hash *json*. May fail if *json* is not a valid hash.
	def initialize(json)
		@time = json["time"] as Int
		@music = json["music"] as Int
		@tileIDs = json["tileIDs"] as Hash
		@tilemap = json["tilemap"] as String
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
end

end # module LE
