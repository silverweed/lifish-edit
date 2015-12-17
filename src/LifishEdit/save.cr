require "./levelset"
require "json"

module LE

class SaveManager
	# Serializes a `LevelSet` into a JSON string, saving it to `fname`
	def self.save(levelset : LE::LevelSet, fname : String)
		output = String.build do |io|
			io.json_object do |obj|
				levelset.metadata.each { |k, v| obj.field k, v }
				obj.field "enemies", levelset.enemies
				obj.field "levels" do
					io.json_array do |arr|
						levelset.each do |level|
							arr << level.serialize
						end
					end
				end
			end
		end
	end

	def self.load(fname : String) : LE::LevelSet
		LE::LevelSet.new fname	
	end
end

end # module LE