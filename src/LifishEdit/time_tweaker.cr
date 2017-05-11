require "crsfml/graphics"
require "./buttons"

module LE::LongPressable
	@press_listeners = {} of Symbol => {SF::Time, -> Void}

	# Feeds us with information about long presses.
	def press(what : Symbol?, t : SF::Time)
		# XXX Until they fix https://github.com/crystal-lang/crystal/issues/3512
		#if what == nil
			#@press_listeners.each { |x| x = {SF::Time::Zero, x[1]} }
		#else
			#pl = @press_listeners[what.not_nil!]
			#@press_listeners[what.not_nil!] = {pl[0] + t, pl[1]}
			#if pl[0] + t > SF.seconds(1)
				#pl[1].call
			#end
		#end
	end

	def register(what : Symbol, cb : -> Void)
		@press_listeners[what] = {SF::Time::Zero, cb}
	end
end

class LE::TimeTweaker
	getter back_button, fw_button, time_displayer

	include LongPressable

	def initialize(@app : LE::App)
		@back_button = TextButton.new(@app.font, ->() { back }, "<", 
					      width: 1.2 * LE::TILE_SIZE, height: 1.2 * LE::TILE_SIZE)
		@back_button.fill_color = SF.color(207, 210, 218)
		@back_button.color = SF::Color::Black
		@fw_button = TextButton.new(@app.font, ->() { fw }, ">",
					      width: 1.2 * LE::TILE_SIZE, height: 1.2 * LE::TILE_SIZE)
		@fw_button.fill_color = SF.color(207, 210, 218)
		@fw_button.color = SF::Color::Black
		@time_displayer = TimeDisplayer.new(@app)
		@time = 0.seconds

		register(:back, -> back)
		register(:fw, -> fw)
	end

	def refresh
		@time = @app.lr.level.time.seconds
		@time_displayer.refresh(@time)
	end

	def position=(pos)
		@back_button.position = pos
		@time_displayer.position = SF.vector2f(@back_button.position.x +
						       @back_button.local_bounds.width - 1, pos.y)
		@fw_button.position = SF.vector2f(@time_displayer.position.x +
						  @time_displayer.local_bounds.width - 1, pos.y)
	end

	def position
		@back_button.position
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(@back_button, states)
		target.draw(@time_displayer, states)
		target.draw(@fw_button, states)
	end

	def touch(pos)
		if @back_button.contains?(pos)
			@back_button.callback.call
			return true
		elsif @fw_button.contains?(pos)
			@fw_button.callback.call
			return true
		elsif @time_displayer.contains?(pos)
			@time_displayer.selected = true
			refresh
			return true
		end
		false
	end

	def finalize_manual_time
		@app.lr.level.time = @time_displayer.manual_time_buffer_to_seconds
		@time_displayer.finalize_manual_time
		refresh
	end

	private def back
		@app.lr.level.time -= 1 unless @app.lr.level.time == 0
		@time = Time::Span.new(0, 0, @app.lr.level.time)
		refresh
		nil
	end

	private def fw
		@app.lr.level.time += 1
		@time = Time::Span.new(0, 0, @app.lr.level.time)
		refresh
		nil
	end

	class TimeDisplayer < LE::TextButton
		def initialize(app : LE::App)
			super(app.font, ->() {}, width: 2.4 * LE::TILE_SIZE + 1, height: 1.2 * LE::TILE_SIZE)
			@bg_rect.fill_color = SF::Color::White
			@text.color = SF::Color::Black
			@manual_time_buffer = [] of Int32
		end

		def draw(target, states : SF::RenderStates)
			super
		end

		def refresh(time = nil)
			if @selected
				n = manual_time_buffer_to_seconds
				@text.string = (n > 0 ? n.to_s : "") + "_"
			elsif !time.nil?
				@text.string = "#{time.minutes}m #{time.seconds}s"
			end
			@bg_rect.fill_color = @selected ? SF::Color::Cyan : SF::Color::White
			center_text
		end

		def update_manual_time(n : Int32)
			@manual_time_buffer << n
			refresh
		end

		def finalize_manual_time
			@manual_time_buffer.clear
			@selected = false
		end

		# Returns the input time in seconds
		def manual_time_buffer_to_seconds : Int32
			s = 0
			@manual_time_buffer.reverse.each_with_index do |n, i|
				s += n * 10**i
			end
			s
		end
	end
end
