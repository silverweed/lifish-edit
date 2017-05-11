require "crsfml/graphics"
require "./app"

module LE

class FeedbackText
	
	FADE_DURATION = SF.seconds(2)

	def initialize(app : LE::App)
		@text = SF::Text.new("", app.font, 18)
		@text.fill_color = SF::Color.new(0, 255, 0, 0)
		@text.outline_color = SF::Color.new(0, 150, 0, 0)
		@text.outline_thickness = 1
		@clock = SF::Clock.new
	end
	
	def show(str)
		@text.string = str
		b = @text.local_bounds
		@text.position = SF.vector2f(LE::WIN_WIDTH - b.width - 3.0, LE::MENU_HEIGHT + 3.0)
		fc = @text.fill_color
		@text.fill_color = SF::Color.new(fc.r, fc.g, fc.b, 255)
		oc = @text.outline_color
		@text.outline_color = SF::Color.new(oc.r, oc.g, oc.b, 255)
		@clock.restart
	end
	
	def refresh
		c = @text.fill_color
		if c.a > 0
			@text.fill_color = SF::Color.new(c.r, c.g, c.b, c.a - {c.a, 255/60}.min)
			oc = @text.outline_color
			@text.outline_color = SF::Color.new(oc.r, oc.g, oc.b, @text.fill_color.a)
		end
	end

	include SF::Drawable

	def draw(target, states : SF::RenderStates)
		target.draw(@text, states)
	end
end

end
