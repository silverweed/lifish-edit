# getopt.cr - macro to get options

# **getopt!** must be given an array of tuples like:
# ```
# getopt!([{ "-l", :levels, String }, { "-v", :verbose }])
# ```
# and it will fill global variables $_options and $_args
# respectively with a hash of all the options
# with their values and an array of all non-options arguments.
# If the passed tuple has a 3rd element, the option requires
# an argument of the specified type; else, it's treated as a
# boolean flag.
# In the example above, if the command line arguments are:
# ```text
# ./main -l levels.json /my/path -v
# ```
# getopt will yield:
# ```
# $_options = {:levels => "levels.json", :verbose => true}
# $_args = ["/my/path"]
# ```
macro getopt!(optlist)
	%i = 0
	%opts_ended = false
	$_options = {} of Symbol => Int64|Float64|String|Bool
	$_args = [] of String
	while %i < ARGV.size
		unless %opts_ended
			case ARGV[%i]
			when "--"
				%opts_ended = true
			{% for opt in optlist %}
			when {{opt[0]}}
				{% if opt.size < 3 %}
				# unary flag
				$_options[{{opt[1]}}] = true
				{% else %}
				# needs an argument
				%i += 1
				if %i == ARGV.size
					raise "Expected argument after #{ARGV[%i - 1]}"
				elsif !ARGV[%i].is_a? {{opt[2]}}
					raise "Invalid type for option #{ARGV[%i - 1]} \
					       (#{typeof(ARGV[%i - 1])} instead of #{{{opt[2]}}})"
				end
				$_options[{{opt[1]}}] = ARGV[%i]
				{% end %}
			{% end %}
			else
				if ARGV[%i][0] == '-'
					raise "Unknown option: #{ARGV[%i]}"
				else
					$_args << ARGV[%i]
				end
			end
		else
			$_args << ARGV[%i]
		end
		%i += 1
	end
end
