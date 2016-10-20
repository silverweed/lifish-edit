# Lifish Edit
# by Giacomo Parolini
#
# Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

options = getopt [
	{ "-v", :verbose }, # whether to be verbose or not
	{ "-V", :version }, # only output program version
	{ "-h", :help },    # only output help
	{ "-g", :graphics_dir, String }, # manually select graphics dir
]

if options[:version]
	puts "LifishEdit #{LE::VERSION} by Giacomo Parolini"
	puts "  * compiled with Crystal #{Crystal::VERSION}"
	puts "  * using CrSFML #{SF::VERSION}"
	puts "  * LifishEdit is free software release under the MIT license"
	puts "  * source code available at https://github.com/silverweed/lifish-edit"
	puts "  * get Lifish for free at https://github.com/silverweed/lifish"
	exit 0
end

def help
	puts "Usage: #{$0} [flags] <levelset>"
	puts "flags:"
	puts "        -h: print this help and exit"
	puts "        -g: graphics directory (default: lifish_dir/assets/graphics)"
	puts "        -v: be verbose"
	puts "        -V: print version and exit"
	exit 0
end

help if options[:help]

args = options[:args].as Array(String)
cfg = LE::Utils.read_cfg_file

STDERR.puts "options: #{options}; args: #{args}"
STDERR.flush

levels_json = ""

if ARGV.size > 0
	levels_json = args[0]
else
	start_dir = cfg["start_dir"]? || ENV["HOME"]
	case LibNFD.open_dialog(nil, start_dir, out levels_json_ptr)
	when LibNFD::Result::ERROR
		raise "Error selecting directory!"
	when LibNFD::Result::CANCEL
		raise "Directory not selected!"
	else
		levels_json = String.new(levels_json_ptr)
	end
end

raise "Invalid levels_json selected!" unless levels_json.size > 0 

app = LE::App.new(levels_json, options[:graphics_dir] ? options[:graphics_dir].as String : nil)
app.verbose = !!options[:verbose]
lr = app.lr
window = app.window
ls = app.ls
lr.load_level
app.sidebar.refresh

LE::Utils.write_cfg_file("start_dir", File.dirname(levels_json))

class LE::App
	def place_entity
		tile = mouse_utils.get_touched_tile
		if @selected_entity != nil && tile.is_a? Tuple
			history.save
			lr.place_entity(tile, @selected_entity.not_nil!)
		end
	end
end

def highlight_tile(window, app)
	touched = app.mouse_utils.get_touched_tile
	hlrect = SF::RectangleShape.new(SF.vector2f(LE::TILE_SIZE, LE::TILE_SIZE))
	hlrect.fill_color = SF.color(200, 200, 200, 70)
	hlrect.outline_color = SF.color(0, 0, 0, 255)
	hlrect.outline_thickness = 2
	draw = false

	if touched
		x, y = touched.as Tuple(Int32, Int32)
		hlrect.position = SF.vector2f((x + 1) * LE::TILE_SIZE + LE::SIDE_PANEL_WIDTH,
					      (y + 1) * LE::TILE_SIZE + LE::MENU_HEIGHT)
		draw = true
	else
		btn = app.sidebar.get_touched_button(window.map_pixel_to_coords(SF::Mouse.get_position(window)))
		if btn
			hlrect.position = btn
			hlrect.size = SF.vector2f(1.2 * LE::TILE_SIZE, 1.2 * LE::TILE_SIZE)
			draw = true
		end
	end

	window.draw(hlrect) if draw
end

def keep_ratio(size, designedsize)
	viewport = SF::FloatRect.new(0_f32, 0_f32, 1_f32, 1_f32)
	screenw = size.width / designedsize[0].to_f32
	screenh = size.height / designedsize[1].to_f32

	if screenw > screenh
		viewport.width = screenh / screenw
		viewport.left = (1 - viewport.width) / 2_f32
	elsif screenh > screenw
		viewport.height = screenw / screenh
		viewport.top = (1 - viewport.height) / 2_f32
	end

	view = SF::View.new(SF::FloatRect.new(0_f32, 0_f32, designedsize[0].to_f32, designedsize[1].to_f32))
	view.viewport = viewport
	return view
end

while window.open?
	while event = window.poll_event
		case event
		when SF::Event::Closed
			window.close
		
		when SF::Event::Resized
			window.view = keep_ratio(event, {LE::WIN_WIDTH, LE::WIN_HEIGHT})

		when SF::Event::KeyPressed
			case event.code
			when SF::Keyboard::Add
				lr.save_level
				lr.level = ls.next
			when SF::Keyboard::Subtract
				lr.save_level
				lr.level = ls.prev
			when SF::Keyboard::Z
				if SF::Keyboard.key_pressed?(SF::Keyboard::LControl)
					app.history.step_back
				end
			when SF::Keyboard::Y
				if SF::Keyboard.key_pressed?(SF::Keyboard::LControl)
					app.history.step_forward
				end
			when SF::Keyboard::F
				app.show_fps = !app.show_fps
			end

		when SF::Event::MouseButtonPressed
			touched = app.mouse_utils.get_touched 
			
			if app.verbose?
				puts "Mouse in #{SF::Mouse.get_position window};" +
					" tile = #{app.mouse_utils.get_touched_tile};" +
					" touched = #{touched}" 
			end

			if touched.is_a? LE::MenuCallback
				callback = touched
				exit 0 unless callback.call(app)
			else
				case event.button
				when SF::Mouse::Left
					app.place_entity
				when SF::Mouse::Right
					if touched.is_a? LE::Entity
						app.history.save
						lr.remove_entity(touched) 
					end
				end
			end

		when SF::Event::MouseMoved
			if SF::Mouse.button_pressed?(SF::Mouse::Left)
				app.place_entity
			elsif SF::Mouse.button_pressed?(SF::Mouse::Right)
				touched = app.mouse_utils.get_touched
				if touched.is_a? LE::Entity
					app.history.save
					lr.remove_entity(touched) 
				end
			end
		end
	end
	window.clear
	window.draw app
	highlight_tile(window, app)
	window.display
end
