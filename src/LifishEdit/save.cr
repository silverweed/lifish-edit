require "./levelset"
require "json"

class LE::SaveManager
	# Serializes a `LevelSet` into a JSON string, saving it to `fname`
	def self.save(levelset : LE::LevelSet, fname : String)
		fname += ".json" unless fname.ends_with? ".json"
		levelset.date = Time.now.to_s
		File.write(fname, levelset.data.to_pretty_json("\t"))
		if levelset.app.verbose?
			STDERR.puts "Saved levelset in #{fname}"
		end
	end

	def self.load(app : LE::App, fname : String) : LE::LevelSet
		app.ls = LE::LevelSet.new(app, fname)
	end
end
