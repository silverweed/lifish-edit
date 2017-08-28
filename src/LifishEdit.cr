# LifishEdit - level editor for Lifish
# Copyright (C) 2017 Giacomo Parolini
#
# This software is provided 'as-is', without any express or implied
# warranty.  In no event will the authors be held liable for any damages
# arising from the use of this software.
#
# Permission is granted to anyone to use this software for any purpose,
# including commercial applications, and to alter it and redistribute it
# freely, subject to the following restrictions:
#
# 1. The origin of this software must not be misrepresented; you must not
# claim that you wrote the original software. If you use this software
# in a product, an acknowledgment in the product documentation would be
# appreciated but is not required.
# 2. Altered source versions must be plainly marked as such, and must not be
# misrepresented as being the original software.
# 3. This notice may not be removed or altered from any source distribution.
#
# Application entry point

require "./LifishEdit/*"
require "./clibs/*"
require "crsfml/graphics"
require "crsfml/window"

options = getopt [
	{ "-v", :verbose, "be verbose" },
	{ "-V", :version, "print version and exit" },
	{ "-h", :help, "print this help and exit" },
	{ "-g", :graphics_dir, "select graphics directory (default: lifish_dir/assets/graphics)", String },
], "Usage: #{$0} [options] <levelset>"

if options[:version]
	puts "LifishEdit #{LE::VERSION} by Giacomo Parolini"
	puts "  * compiled with Crystal #{Crystal::VERSION}"
	puts "  * using CrSFML #{SF::VERSION}"
	puts "  * LifishEdit is free software release under the zlib/libpng license"
	puts "  * source code available at https://github.com/silverweed/lifish-edit"
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

if options[:args].as(Array(String)).size > 0
	levels_json = args[0]
else
	start_dir = cfg["start_dir"]? || ENV["HOME"]
	case LibNFD.open_dialog("json", start_dir, out levels_json_ptr)
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

# Start with a default selected entity
app.selected_entity = app.sidebar.touch(app.sidebar.entity_buttons[0].position)

LE::Utils.write_cfg_file("start_dir", File.dirname(levels_json))

alias Kb = SF::Keyboard
while window.open?
	while event = window.poll_event
		case event
		when SF::Event::Closed
			window.close
		
		when SF::Event::Resized
			window.view = keep_ratio(event, {LE::WIN_WIDTH, LE::WIN_HEIGHT})

		when SF::Event::KeyPressed
			case event.code
			when Kb::Return
				# Horrible hardcoded behaviour, probably will change this in future
				if app.sidebar.time_tweaker.time_displayer.selected
					app.sidebar.time_tweaker.finalize_manual_time
				else
					window.close if app.quit_prompt.active
				end
			when Kb::Add
				lr.save_level
				lr.level = ls.next
			when Kb::Subtract
				lr.save_level
				lr.level = ls.prev
			when Kb::C
				if Kb.key_pressed?(Kb::LControl)
					app.copy_level
				end
			when Kb::V
				if Kb.key_pressed?(Kb::LControl)
					app.paste_level
				end
			when Kb::F
				app.show_fps = !app.show_fps
			when Kb::H
				app.toggle_help
			when Kb::Num0 .. Kb::Num9,
			     Kb::Numpad0 .. Kb::Numpad9
				if app.sidebar.time_tweaker.time_displayer.selected
					app.sidebar.time_tweaker.time_displayer.update_manual_time(
						LE::Utils.code2num(event.code))
				else
					app.jump_to_lv(LE::Utils.code2num(event.code))
				end
			# Control sequences
			when Kb::Z
				if Kb.key_pressed?(Kb::LControl)
					app.history.step_back
					app.feedback_text.show("Undo: place entity")
				end
			when Kb::Y
				if Kb.key_pressed?(Kb::LControl)
					app.history.step_forward
					app.feedback_text.show("Redo: place entity") 
				end
			when Kb::S
				if Kb.key_pressed?(Kb::LControl)
					if Kb.key_pressed?(Kb::LShift)
						app.menu.invoke(:save_as, app)
					else
						app.menu.invoke(:save, app)
					end
				end
			when Kb::Q
				app.quit_prompt.active = true if Kb.key_pressed?(Kb::LControl)
			end

		when SF::Event::MouseButtonPressed
			touched = app.mouse_utils.touch
			
			if app.verbose?
				puts "Mouse in #{SF::Mouse.get_position window};" +
					" tile = #{app.mouse_utils.get_touched_tile};" +
					" touched = #{touched}"
			end

			case event.button
			when SF::Mouse::Left
				if touched.is_a? LE::MenuCallback
					callback = touched
					window.close unless callback.call(app)
				elsif Kb.key_pressed?(Kb::LShift)
					app.remove_entity
				else
					app.place_entity
				end
			when SF::Mouse::Right
				app.remove_entity
			when SF::Mouse::XButton1
				lr.save_level
				lr.level = ls.prev
			when SF::Mouse::XButton2
				lr.save_level
				lr.level = ls.next
			end


		when SF::Event::MouseMoved
			if SF::Mouse.button_pressed?(SF::Mouse::Left)
				if Kb.key_pressed?(Kb::LShift)
					app.remove_entity
				else
					app.place_entity
				end
			elsif SF::Mouse.button_pressed?(SF::Mouse::Right)
				app.remove_entity
			end

		when SF::Event::MouseWheelScrolled
			lr.save_level
			event.delta.to_i.abs.times { lr.level = ls.cyclic(event.delta > 0) }
		end
	end
	app.refresh
	window.clear
	window.draw(app)
	app.highlight_tile(window)
	window.display
end
