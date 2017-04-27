require "crsfml/graphics"
require "./app"
require "./popup"

class LE::Help < LE::Popup
	def initialize(app : LE::App)
		super(app, SF.vector2f(LE::WIN_WIDTH * 2/3, LE::WIN_HEIGHT * 4/5))
	end

	protected def init
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
