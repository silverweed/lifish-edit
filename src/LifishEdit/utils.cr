module LE
	# Contains various utility functions and macros.
	module Utils
		extend self

		CFG_FILE = ".lifishedit.cfg"

		macro get_graphic!(name)
			"#{(@app as LE::App).lifish_dir}/assets/graphics/#{{{name}}}"
		end

		# Attempts to read the config file `CFG_FILE` and returns a Hash
		# (possibly empty) with pairs Key => Value of the config.
		def read_cfg_file : Hash(String, String)
			cfg = {} of String => String
			File.open("#{File.dirname $0}/#{CFG_FILE}", "r").each_line do |line|
				next if line.starts_with? "#"
				s = line.split(" ", 2)
				next unless s.size == 2
				key, val = s
				cfg[key] = val
			end
			cfg
		rescue err
			STDERR.puts "Error reading from cfg file: \n#{err}"
			{} of String => String
		end

		# Writes the starting directory to the cfg file
		def write_cfg_file(key, val)
			cfg = read_cfg_file
			cfg[key] = val
			File.open("#{File.dirname $0}/#{CFG_FILE}", "w") do |file|
				file.puts "#{key} #{cfg[key]}"
			end
		rescue err
			STDERR.puts "Couldn't save lifish directory: \n#{err}"
		end
	end
end
