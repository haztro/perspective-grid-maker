extends Node2D


onready var main_camera = get_node("Camera2D")
onready var screen_state = get_node("/root/ScreenState")
onready var screen_toolbox = get_node("UI/ScreenToolbox")
onready var background = get_node("bg")

var grid_3d_viewport = preload("res://3DGrid/Viewport3D.tscn")
var toolbox_3d = preload("res://3DToolbox/3DToolbox.tscn")
var grid_2d_viewport = preload("res://2DGrid/Viewport2D.tscn")
var toolbox_2d = preload("res://2DToolbox/2DToolbox.tscn")

var grid_viewport = null
var grid_3d = null
var toolbox = null

var is_dragging = 0
var is_translating = 0
var mouse_on_grid = 0
var is_zooming = 0
var last_drag_pos = Vector2(0, 0)
var last_translate_pos = Vector2(0, 0)
var mode_2d = 0

var min_zoom = 20
var max_zoom = 0.1
var zoom_step = 0
var max_zoom_steps = 100
var zoom_val = 1

var license = """
GODOT LICENSE 

Copyright (c) 2007-2020 Juan Linietsky, Ariel Manzur.
Copyright (c) 2014-2020 Godot Engine contributors (cf. AUTHORS.md).

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED \"AS IS\", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

Portions of this software are copyright © 2020 The FreeType Project (www.freetype.org). All rights reserved.

"""

# Called when the node enters the scene tree for the first time.
func _ready():
	print(license)
	
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	screen_toolbox.connect("fit_to_window", self, "_on_fit_to_window")
	screen_toolbox.main = self
	screen_toolbox.get_node("SaveGridDialog").main = self
	_on_viewport_size_changed()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):

	if !screen_state.input_busy and toolbox != null and grid_viewport != null:
		if is_dragging:
			update_grid_view()
		if is_translating:
			translate_grid()
	
# Get all input
func _input(event):
	
	if event.is_action_pressed("fullscreen") and !screen_state.window_open:
		OS.window_fullscreen = !OS.window_fullscreen
	
	if OS.get_name() == "Android":
		if !screen_state.window_open:
			if event is InputEventScreenTouch:
				# Dragging/Moving screen
				if event.pressed and !screen_state.input_busy:
					last_drag_pos = event.position
					is_dragging = 1
				elif !event.pressed:
					is_dragging = 0
#
			if event is InputEventScreenDrag:
				last_drag_pos = event.position
	else:
		if !screen_state.window_open:
			if event is InputEventMouseButton:
				# Dragging/Moving screen
				if event.button_index == BUTTON_LEFT:
					if event.is_pressed() and !screen_state.input_busy:
						last_drag_pos = get_viewport().get_mouse_position()
						is_dragging = 1
					else:
						is_dragging = 0
						
				elif event.button_index == BUTTON_MIDDLE:
					if event.is_pressed() and !screen_state.input_busy:
						last_translate_pos = get_viewport().get_mouse_position()
						is_translating = 1
					else:
						is_translating = 0
				
				# Zooming screen
				if event.button_index == BUTTON_WHEEL_UP and !screen_state.input_busy:
					zoom_camera(-1)
				elif event.button_index == BUTTON_WHEEL_DOWN and !screen_state.input_busy:
					zoom_camera(1)
						
					
func save_grid(mode, file_location, file_name):
	screen_state.exporting = 1
	if !mode_2d:
		var cube_vis = grid_3d.get_node("Cube").visible
		grid_3d.set_cube_visibility(false)
		
		yield(VisualServer, 'frame_post_draw')
		
		if mode:
			for l in ["x", "y", "z", "zy"]:		
				if grid_3d.check_visibility(l):
					grid_3d.isolate_visibility(l)
					yield(VisualServer, 'frame_post_draw')
					var img = grid_viewport.get_texture().get_data()
					var n = file_location + "/" + file_name + "_" + l + ".png"
					img.flip_y()	
					var err = img.save_png(n)
				
					# Reset grid back to before export	
					toolbox.set_grid_with_tool()
		else:
			var img = grid_viewport.get_texture().get_data()
			var n = file_location + "/" + file_name + ".png"
			img.flip_y()
			var err = img.save_png(n)
				
			
		grid_3d.set_cube_visibility(cube_vis)
		
	else:	
		if mode:
			var count = 0
			for c in grid_viewport.get_children():
				if c.visible:	
					for d in grid_viewport.get_children():
						if c != d:
							d.visible = false
							
					yield(VisualServer, 'frame_post_draw')
					var img = grid_viewport.get_texture().get_data()
					var n = file_location + "/" + file_name + "_" + str(count) + ".png"
					img.flip_y()	
					var err = img.save_png(n)
					
					toolbox.set_grid_with_tool()
					count += 1
		else:
			yield(VisualServer, 'frame_post_draw')
			var img = grid_viewport.get_texture().get_data()
			var n = file_location + "/" + file_name + ".png"
			img.flip_y()
			var err = img.save_png(n)
	
	screen_state.exporting = 0
	return 0
			


func make_new_grid(mode, grid_size):
	mode_2d = mode

	
	if screen_state.trial:
		$demo.visible = true
		
	# Destroy the current viewport
	if grid_viewport != null:
		$ViewportContainer.remove_child(grid_viewport)
		grid_viewport.queue_free()
	
	# Destroy toolbox and any remaining vanishing points	
	for c in $UI.get_children():
		if c.name != "ScreenToolbox":
			c.queue_free()

	# Set the grid viewport size
	screen_state.grid_size = grid_size
	$Border.visible = true
	
	$bg.visible = false
	
	if !mode_2d:
		grid_viewport = grid_3d_viewport.instance()
		grid_viewport.size = grid_size
		$ViewportContainer.add_child(grid_viewport)
		grid_viewport.get_node("Camera/Camera360").update_size(grid_viewport.size)
		grid_3d = grid_viewport.get_node("Grid")
		toolbox = toolbox_3d.instance()
		$UI.add_child(toolbox)
		toolbox.set_grid(grid_3d)
		toolbox.main = self
		grid_3d.redraw_all()
	else:
		grid_viewport = grid_2d_viewport.instance()
		grid_viewport.size = grid_size
		$ViewportContainer.add_child(grid_viewport)
		toolbox = toolbox_2d.instance()
		toolbox.main = self
#		toolbox.set_hv_settings()
		$UI.add_child(toolbox)
		
	screen_toolbox.set_size_box(grid_size)
	screen_toolbox.set_size_visible(true)
	
	$UI.move_child(toolbox, 0)
	
	# "Resize" and redraw viewport
	$ViewportContainer.visible = false
	$ViewportContainer.visible = true
	_on_fit_to_window()


func zoom_camera(dir):
	var new_zoom = clamp(main_camera.zoom.x + dir * 0.05, max_zoom, min_zoom)
	main_camera.zoom = Vector2(new_zoom, new_zoom)
	screen_state.main_camera_zoom = main_camera.zoom
	$Border._on_viewport_size_changed()
	
# Translate the grid camera by the amount the mouse has moved since last frame.
func update_grid_view():
	var mouse_pos = get_viewport().get_mouse_position()
	
	if !mode_2d:
		grid_3d.rotate_grid(last_drag_pos - mouse_pos)
	
	last_drag_pos = mouse_pos
	screen_state.main_camera_pos = main_camera.position
	
func translate_grid():
	var mouse_pos = get_viewport().get_mouse_position()
	
	main_camera.position += (last_translate_pos - mouse_pos) * main_camera.zoom
	
	last_translate_pos = mouse_pos
	screen_state.main_camera_pos = main_camera.position
	
func set_background(texture, new_size):
	screen_state.grid_size = new_size
	screen_toolbox.set_size_box(new_size)
	
	if grid_viewport != null:
		resize_viewport(new_size)
		
	background.rect_size = new_size
	background.texture = texture
	background.visible = true
	
	_on_fit_to_window()
	
# Ensure that the grid viewport fills up the whole screen
func set_main_camera_scale():
	if toolbox != null and grid_viewport != null:
		var window_size = OS.get_window_size()
		window_size.x = window_size.x - screen_toolbox.rect_size.x - toolbox.rect_size.x
		
		main_camera.position.x = -((screen_toolbox.rect_size.x + (window_size.x - grid_viewport.size.x / main_camera.zoom.x) / 2) * main_camera.zoom.x)
		main_camera.position.y = -((window_size.y - grid_viewport.size.y / main_camera.zoom.y) / 2) * main_camera.zoom.y
		main_camera.position += OS.get_window_size() * main_camera.zoom / 2
		
		screen_state.main_camera_pos = main_camera.position
		
func _on_fit_to_window():
	if toolbox != null and grid_viewport != null:
		var window_size = OS.get_window_size()
		window_size.x = window_size.x - screen_toolbox.rect_size.x - toolbox.rect_size.x

		var m = min(window_size.x / grid_viewport.size.x, window_size.y / grid_viewport.size.y)
		var d = (window_size - grid_viewport.size * m) / 2
		main_camera.position.x = -(d.x + screen_toolbox.rect_size.x) / m
		main_camera.position.y = -(d.y) / m
		main_camera.zoom = Vector2(1/m, 1/m)
		main_camera.position += OS.get_window_size() * main_camera.zoom / 2
				
		screen_state.main_camera_zoom = main_camera.zoom
		screen_state.main_camera_pos = main_camera.position
	
		$Border._on_viewport_size_changed()
	
func resize_viewport(new_size):
	grid_viewport.size = new_size
	screen_state.grid_size = new_size
	$ViewportContainer.visible = false
	$ViewportContainer.visible = true
	
	if screen_state.trial:
		$demo.rect_size = new_size
		
	if !mode_2d:
		grid_viewport.get_node("Camera/Camera360").update_size(grid_viewport.size)
	
	if toolbox != null:
		screen_state.useable_width = OS.get_screen_size().x - screen_toolbox.rect_size.x - toolbox.rect_size.x
		
	$Border._on_viewport_size_changed()
	set_main_camera_scale()
	
func _on_viewport_size_changed():
	if toolbox != null:
		screen_state.useable_width = OS.get_screen_size().x - screen_toolbox.rect_size.x - toolbox.rect_size.x
	$Border._on_viewport_size_changed()
	_on_fit_to_window()
	set_main_camera_scale()


func _on_ScreenToolbox_update_tooltip(value):
	if value:
		ProjectSettings.set_setting("gui/timers/tooltip_delay_sec", 0.5)
	else:
		ProjectSettings.set_setting("gui/timers/tooltip_delay_sec", 5)
