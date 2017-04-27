require "crsfml/graphics"
require "./app"
require "./utils"

abstract class LE::Popup
	property active

	include SF::Drawable

	def initialize(@app : LE::App, dims : SF::Vector2f)
		@active = false
		@rect = SF::RectangleShape.new(dims)
		@rect.fill_color = SF::Color::White
		@rect.outline_color = SF::Color::Black
		@rect.outline_thickness = 2
		@rect.position = LE::Utils.centered(@rect.local_bounds)
		@texts = [] of SF::Text
		@initialized = false
	end

	def draw(target, states : SF::RenderStates)
		return unless @active
		init unless @initialized
		target.draw(@rect, states)
		@texts.each { |t| target.draw(t, states) }
	end

	abstract def init
end
