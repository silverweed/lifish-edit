# levelset.cr - The level set contains all levels and is able
# to translate them to JSON and vice-versa.

require "json"
require "./data"

# A **LevelSet** contains an array of `Level`s.
# The LevelSet is constructed with a JSON lifish levels file
# containing the levels data and metadata.
class LE::LevelSet

	getter app
	property json_fname
	getter data

	# Opens file `@json_fname` containing a lifish level set
	# and deserializes it.
	def initialize(@app : LE::App, @json_fname : String)
		@data = LE::Data::LevelSetData.from_json(File.open(@json_fname, "r"))
		@data.comment = "Created with LifishEdit #{LE::VERSION}"

		@levels = [] of LE::Level
		# currently pointed level
		@current = 0

		# Generate levels
		lvjson = @data.levels
		i = 1_u32
		lvjson.each do |description|
			begin
				@levels << LE::Level.new(description, i)
			rescue e
				STDERR.puts "Couldn't create level #{i}:"
				STDERR.puts e.backtrace.join "\n"
			end
			i += 1
		end
	end

	def [](i)
		@levels[i % n_levels]
	end

	def set(i)
		@current = i % n_levels
		@levels[@current]
	end

	def n_levels
		@levels.size
	end
	
	def metadata
		{
			name: data.name,
			author: data.author,
			difficulty: data.difficulty,
		}
	end

	def each
		@levels.each do |level|
			yield level
		end
		self
	end

	def cur_level
		@current + 1
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
		puts "LevelSet: #{@data.name || "Unnamed set"}\n\
			Author: #{@data.author || "Unknown"}\n\
			Difficulty: #{@data.difficulty || "Unknown"}\n\
			Created: #{@data.created || "Unknown"}\n\
			Comment: #{@data.comment || "--"}\n\
			#Tracks: #{@data.tracks.size}\n\
			#Levels: #{@data.levels.size}"
	end

	def date=(date)
		@data.created = date
	end
end
