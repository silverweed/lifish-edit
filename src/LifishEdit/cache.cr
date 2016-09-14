require "crsfml/graphics"
require "./utils"

module LE

class Cache
	def initialize(@app : LE::App)
		@textures = {} of String => SF::Texture
	end

	def texture(key : String)
		return @textures[key] if @textures.has_key? key
		begin
			STDERR.puts "Loading #{key}"
			return @textures[key] = SF::Texture.from_file(LE::Utils.get_graphic(key))
		rescue e
			STDERR.puts "Error loading texture #{key}: #{e}"
			return nil
		end
	end

end

end # module LE
