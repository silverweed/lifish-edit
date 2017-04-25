# getopt.cr - macro to get options

# **getopt** must be given an array of tuples like:
# ```
# # [{ flag, option_name, description[, type] }]
# getopt([{ "-l", :levels, "select levels", String }, { "-v", :verbose, "be verbose" }])
# ```
# and it will return a variable %options containing a hash 
# of all the options with their values and an array of all
# non-options arguments under the key [:args].
# If the passed tuple has a 3rd element, the option requires
# an argument of the specified type; else, it's treated as a
# boolean flag.
# In the example above, if the command line arguments are:
# ```text
# ./main -l levels.json /my/path -v
# ```
# getopt will yield:
# ```
# {:args => ["/my/path"], :levels => "levels.json", :verbose => true}
# ```
macro getopt(optlist, help_head = "")
	%i = 0
	%opts_ended = false
	%options = {} of Symbol => Array(String)|Int64|Float64|String|Bool
	%args = [] of String
	
	# Fill %options of false values
	{% for opt in optlist %}
	%options[{{opt[1]}}] = false
	{% end %}

	print_help = ->() {
		puts {{help_head}} if {{help_head}}.size > 0
		puts "Options:"
		{% for opt in optlist %}
			{% if opt.size < 4 %}
				puts "\t#{{{opt[0]}}}: #{{{opt[2]}}}"
			{% else %}
				puts "\t#{{{opt[0]}}} <#{{{opt[3]}}}>: #{{{opt[2]}}}"
			{% end %}
		{% end %}
		exit
	}

	while %i < ARGV.size
		unless %opts_ended
			case ARGV[%i]
			when "--"
				%opts_ended = true
			{% for opt in optlist %}
			when {{opt[0]}}
				{% if opt.size < 4 %}
					# unary flag
					%options[{{opt[1]}}] = true
				{% else %}
				# needs an argument
				%i += 1
				if %i == ARGV.size
					puts "Expected #{{{opt[3]}}} argument after #{ARGV[%i - 1]}"
					exit 1
				elsif !ARGV[%i].is_a? {{opt[3]}}
					puts "Invalid type for option #{ARGV[%i - 1]} \
					       (#{typeof(ARGV[%i - 1])} instead of #{{{opt[3]}}})"
				       exit 1
				end
				%options[{{opt[1]}}] = ARGV[%i].as {{opt[3]}}
				{% end %}
			{% end %}
			else
				if ARGV[%i][0] == '-'
					STDERR.puts("Unknown option: #{ARGV[%i]}")
					print_help.call
				else
					%args << ARGV[%i]
				end
			end
		else
			%args << ARGV[%i]
		end
		%i += 1
	end
	%options[:args] = %args
	%options
end
