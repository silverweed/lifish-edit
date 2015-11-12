require "crsfml/window_obj"

module LE

class MouseUtils
	def initialize(@lr : LE::LevelRenderer)
	end

	def get_touched_entity
		@lr.tiles.each do |tile|
			
		end
	end
end

end # module LE
