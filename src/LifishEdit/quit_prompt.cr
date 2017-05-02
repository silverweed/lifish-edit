require "crsfml/graphics"
require "./app"
require "./popup"
require "./buttons"

class LE::QuitPrompt < LE::Popup
	def initialize(app : LE::App)
		super(app, SF.vector2f(LE::WIN_WIDTH * 0.3, LE::WIN_HEIGHT * 0.2))
		@buttons = [] of LE::TextButton
	end

	def draw(target, states : SF::RenderStates)
		super
		@buttons.each { |btn| target.draw(btn, states) } if @active
	end

	def touch(pos)
		@buttons.each do |btn|
			if btn.contains?(pos)
				btn.callback.call
				return
			end
		end
	end

	protected def init
		txt = SF::Text.new("Really quit?", @app.font, 24)
		txt.fill_color = SF::Color::Black
		txt.position = @rect.position + SF.vector2f(10, 10)
		@texts << txt
		b = @rect.local_bounds
		tb = txt.local_bounds
		yes_btn = LE::TextButton.new(@app.font, ->() { @app.window.close }, "Yes", b.width / 4, b.height / 4)
		yes_btn.position = txt.position + SF.vector2f(0, tb.height + 10)
		yes_btn.soft_selected = true
		@buttons << yes_btn
		tb = yes_btn.local_bounds
		no_btn = LE::TextButton.new(@app.font, ->() { @active = false; nil }, "No", b.width / 4, b.height / 4)
		no_btn.position = yes_btn.position + SF.vector2f(tb.width + 10, 0)
		@buttons << no_btn
	end
end
