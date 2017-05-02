require "crsfml/graphics"
require "./utils"

class LE::Cache
	def initialize(@app : LE::App)
		@textures = {} of String => SF::Texture
	end

	# Load and return texture `key`.
	# If `key` is a relative path, assume base dir is `(lifish_dir)/assets/graphics`.
	def texture(key : String) : SF::Texture?
		return @textures[key] if @textures.has_key?(key)
		path = if key == File.basename(key)
			       LE::Utils.get_graphic(key)
		       else
			       key
		       end
		begin
			STDERR.puts "Loading #{path}"
			return @textures[key] = SF::Texture.from_file(path)
		rescue e
			STDERR.puts "Error loading texture #{path}: #{e}"
			return nil
		end
	end

end
