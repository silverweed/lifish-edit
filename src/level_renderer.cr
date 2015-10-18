require "crsfml/graphics"

module LE

class LevelRenderer
	getter level

	def initialize(@level)
		@tiles = [] of Entity?
		load_level
	end

	def level=(@level)
		load_level
	end

	private def load_level
		@tiles = [] of Entity?
		@level.tilemap.each_char do |c|
			break if c == '\0'
			case entity = LE.get_entity c
			when :unknown
				STDERR.puts "Invalid tile for level: #{c}. Setting tile to empty."
				@tiles << nil
			when :empty
				@tiles << nil
			else
				if $verbose
					STDERR.puts "Creating entity #{c}"
				end
				@tiles << Entity.new entity
			end
		end
	end

	def draw(target, states : SF::RenderStates)
		
	end
end

end # module LE
