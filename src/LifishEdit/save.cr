require "./levelset"
require "json"

module LE

class SaveManager
	# Serializes a `LevelSet` into a JSON string, saving it to `fname`
	def self.save(levelset : LE::LevelSet, fname : String)
		fname += ".json" unless fname.ends_with? ".json"
		File.write(fname, levelset.data.to_pretty_json)
	end

	def self.load(app : LE::App, fname : String) : LE::LevelSet
		app.ls = LE::LevelSet.new(app, fname)
	end
end

end # module LE
