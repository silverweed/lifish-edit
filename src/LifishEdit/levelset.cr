# levelset.cr - The level set contains all levels and is able
# to translate them to JSON and vice-versa.

require "json"

module LE

# A **LevelSet** contains an array of `Level`s.
# The LevelSet is constructed with a JSON lifish levels file
# containing the levels data and metadata.
class LevelSet
	getter json_fname
	getter metadata, enemies

	# Opens file `@json_fname` containing a lifish level set
	# and deserializes it.
	def initialize(@app, @json_fname : String)
		@json = JSON.parse(File.open(@json_fname, "r"))

		# metadata
		@metadata = {
			"name"       => @json["name"].as_s,
			"author"     => @json["author"].as_s,
			"difficulty" => @json["difficulty"].as_s,
			"tracks"     => @json["tracks"]
		}
		@enemies = @json["enemies"]
		@levels = [] of LE::Level
		# currently pointed level
		@current = 0

		# Generate levels
		lvjson = @json["levels"]
		i = 0
		lvjson.each do |description|
			begin
				@levels << LE::Level.new(description)
			rescue e
				STDERR.puts "Couldn't create level #{i}:"
				STDERR.puts e.backtrace.join "\n"
			end
			i += 1
		end
	end

	def [](i)
		@levels[i]
	end

	def each
		@levels.each do |level|
			yield level
		end
		self
	end

	# Returns first non-nil level after the current one, cyclic.
	def next
		cyclic true
	end
	
	def prev
		cyclic false
	end

	def cyclic(forward)
		nils = 0
		while nils < @levels.size
			@current += forward ? 1 : -1
			@current = 0 if @current == @levels.size
			if @levels[@current].is_a? LE::Level
				return @levels[@current]
			else
				nils += 1 
			end
		end
		raise "All levels nil!"
	end
	
	def dump
		puts "LevelSet: #{@name || "Unnamed set"}\n\
			Author: #{@author || "Unknown"}\n\
			Difficulty: #{@difficulty || "Unknown"}\n\
			#Tracks: #{@tracks.size}\n\
			#Levels: #{@levels.size}"
	end
end

end # module LE
