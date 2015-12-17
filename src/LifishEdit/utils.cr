module LE
	module Utils
		extend self

		macro get_graphic!(name)
			"#{$lifish_dir}/assets/graphics/#{{{name}}}"
		end

		# Read the starting directory from a cfg file
		def read_start_dir : String?
			file = File.open "#{File.dirname $0}/.lifishedit.cfg", "r"
			file.read_line.chomp
		rescue 
			nil
		ensure
			file.close if file.is_a? File
		end

		def write_start_dir(dir)
			file = File.open "#{File.dirname $0}/.lifishedit.cfg", "w"
			file.puts dir
		rescue err
			STDERR.puts "Couldn't save lifish directory: \n#{err}"
		ensure
			file.close if file.is_a? File
		end
	end
end
