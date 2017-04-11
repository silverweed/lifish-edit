require "crsfml/graphics"
require "./app"

class LE::Help
	property active

	include SF::Drawable

	def initialize(@app : LE::App)
		@active = false
		@rect = SF::RectangleShape.new(SF.vector2f(LE::WIN_WIDTH * 2/3, LE::WIN_HEIGHT * 4/5))
		@rect.fill_color = SF::Color::White
		@rect.outline_color = SF::Color::Black
		@rect.outline_thickness = 2
		@rect.position = SF.vector2f((LE::WIN_WIDTH - @rect.local_bounds.width) / 2,
		                             (LE::WIN_HEIGHT - @rect.local_bounds.height) / 2)
		@texts = [] of SF::Text
		@initialized = false
	end

	def draw(target, states : SF::RenderStates)
		return unless @active
		init unless @initialized
		target.draw(@rect, states)
		@texts.each { |t| target.draw(t, states) }
	end

	private def init
		h("KEYBINDINGS")
		h("")
		h("LMouse", "Act / Place entity")
		h("RMouse", "Delete entity")
		h("Shift + LMouse", "Delete entity")
		h("MouseWheel", "Navigate levels")
		h("+", "Go to next level")
		h("-", "Go to previous level")
		h("F", "Toggle FPS counter")
		h("H", "Toggle help")
		h("<Number>", "Go to level <Number>")
		h("Ctrl + Z", "Undo")
		h("Ctrl + Y", "Redo")
		h("Ctrl + S", "Save")
		h("Ctrl + Shift + S", "Save As")
		h("Ctrl + Q", "Quit")
		@initialized = true
	end

	private def h(head, desc = nil)
		txt = SF::Text.new(head, @app.font, 14)
		txt.fill_color = SF::Color::Black
		if @texts.size == 0
			txt.position = @rect.position + SF.vector2f(10, 10)
		else
			txt.position = SF.vector2f(@rect.position.x + 10, @texts[-1].position.y + 15)
		end
		@texts << txt
		htxt = txt
		bounds = htxt.local_bounds
		if desc.is_a? String
			txt = SF::Text.new(" - #{desc}", @app.font, 12)
			txt.fill_color = SF::Color::Black
			txt.position = SF.vector2f(@rect.position.x + 150, htxt.position.y)
			@texts << txt
		end
	end
end
