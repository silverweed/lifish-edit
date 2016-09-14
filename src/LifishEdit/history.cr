require "./app"

module LE

# This class holds a stack of pairs (lvnum, tilemap) and allows restoring
# a previous program state via <C-z> / <C-y>
class History
	MAX_HIST_LEN = 50

	def initialize(@app : LE::App)
		@hist = [] of Tuple(Int32, String)
		@i = -1
	end

	def save 
		@app.lr.save_level
		push(@app.ls.cur_level, @app.lr.level.tilemap)
	end

	def step_back
		state = pop
		load_state(state)
	end

	def step_forward
		state = unpop
		load_state(state)
	end

	private def load_state(state)
		return if state == nil
		lvnum, tilemap = state.as Tuple(Int32, String)
		@app.ls[lvnum - 1].tilemap = tilemap
		@app.lr.level = @app.ls[lvnum - 1]
	end

	# Returns currently pointed state and moves the index back. Returns
	# `nil` if the index is < 0.
	private def pop
		return nil if @i < 0
		state = swap_cur
		@i -= 1
		state
	end

	# Moves index 1 step forward and returns the pointed state. Returns
	# `nil` if the index is pointing to the latest added state.
	private def unpop
		return nil if @i == @hist.size - 1
		@i += 1
		swap_cur
	end

	# Inserts current level's state into the currently pointed history
	# entry, then returns the old pointed history entry
	private def swap_cur
		state = @hist[@i]
		@app.lr.save_level
		@hist[@i] = {@app.ls.cur_level, @app.lr.level.tilemap}
		state
	end

	# Adds an element to the history, right after the currently pointed
	# state. If there are more states after the pointed one, they're dropped.
	private def push(lvnum, tilemap)
		if @i < @hist.size - 1
			# We're overwriting successive history: drop it
			@hist = @hist[0 .. @i]
		elsif @hist.size == MAX_HIST_LEN
			# Reached length limit: start dropping old states
			@hist = @hist[1 .. -1]
		end
		@hist << {lvnum, tilemap}
		@i += 1
	end
end

end # module LE
