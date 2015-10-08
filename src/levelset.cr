# levelset.cr - The level set contains all levels and is able
# to translate them to JSON and vice-versa.

require "json"

module LE

class LevelSet
	def initialize(json_fname : String)
		@json = JSON.parse(File.open json_fname, "r") as Hash
		@name = @json["name"] as String|Nil
		@author = @json["author"] as String|Nil
		@difficulty = @json["difficulty"] as String|Nil
		@tracks = @json["tracks"] as Array
		@levels = [] of Level

		# Generate levels
		lvjson = @json["levels"] as Array
		lvjson.each do |description|
			begin
				@levels << Level.new description if description.is_a? Hash
			rescue
			end
		end
	end

	def [](i)
		@levels[i]
	end

	private def init_level(i)
		lvjson = @json["levels"] as Array

		begin
			description = lvjson[i] as Hash
			Level.new description
		rescue
			nil
		end
	end

	def dump
		if false
		puts "
	LevelSet: #{@name || "Unnamed set"}
	Author: #{@author || "Unknown"}
	Difficulty: #{@difficulty || "Unknown"}
	#Tracks: #{@tracks.size}
	#Levels: #{@levels.size}"
		end
	end


end

end # module LE
