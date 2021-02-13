extends Node2D

onready var screen_state = get_node("/root/ScreenState")

signal point_moved(pos)

var line_source = null
var settings = null
var is_dragging = 0
var temp_pos = Vector2(0, 0)
var last_drag_pos = Vector2(0, 0)
var is_locked = 0
var lock_axis = Vector2(0, 0)
var vp_id = 0
var toolbox = null

# Set toolbox reference
# Flag toolbox when click for selected 
# Update selecte

# Called when the node enters the scene tree for the first time.
func _ready():
	temp_pos = screen_state.grid_size / 2
	settings.set_size_box_with_vp(temp_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	position = convert_to_screen(temp_pos)

	if is_dragging:
		var mouse_pos = get_viewport().get_mouse_position()
		
		if mouse_pos.x >= OS.get_window_size().x - toolbox.rect_size.x or mouse_pos.x <= toolbox.main.screen_toolbox.rect_size.x:
			is_dragging = 0
		else:
			temp_pos -= (last_drag_pos - mouse_pos) * screen_state.main_camera_zoom
			temp_pos = Vector2(temp_pos.x, temp_pos.y)
			
			if is_locked:
				do_lock_axis()
			
			last_drag_pos = mouse_pos
			line_source.position = temp_pos
			settings.set_size_box_with_vp(temp_pos)
			
	draw_debug_lines()

func convert_to_screen(pos):
	return (pos + OS.get_window_size() * screen_state.main_camera_zoom / 2 - screen_state.main_camera_pos) / screen_state.main_camera_zoom

func set_locked(value):
	is_locked = value
	if is_locked:
		get_closest_edge()
		do_lock_axis()
		line_source.position = temp_pos
		settings.set_size_box_with_vp(temp_pos)
	
func do_lock_axis():
	if lock_axis.x != -1:
		temp_pos.x = int(lock_axis.x)
	if lock_axis.y != -1:
		temp_pos.y = int(lock_axis.y)
		
func get_closest_edge():
	var d1 = temp_pos.x
	var d2 = temp_pos.y
	var d3 = screen_state.grid_size.x - temp_pos.x
	var d4 = screen_state.grid_size.y - temp_pos.y
	
	if d1 < d2 and d1 < d3 and d1 < d4:
		lock_axis = Vector2(0, -1)
	elif d2 < d1 and d2 < d3 and d2 < d4:
		lock_axis = Vector2(-1, 0)
	elif d3 < d1 and d3 < d2 and d3 < d4:
		lock_axis = Vector2(screen_state.grid_size.x, -1)
	elif d4 < d1 and d4 < d2 and d4 < d3:
		lock_axis = Vector2(-1, screen_state.grid_size.y)

func set_visible(val):
	line_source.visible = val

func set_vp_position(val):
	if screen_state != null:
		temp_pos = val
		line_source.position = val

func set_colour(val):
	line_source.colour = val

func set_grid_spacing(val):
	line_source.density = val

func _on_TextureButton_button_down():
	last_drag_pos = get_viewport().get_mouse_position()
	is_dragging = 1
	toolbox.current_selected = vp_id
	toolbox.update_selected()
	screen_state.input_busy = 1

func _on_TextureButton_button_up():
	is_dragging = 0
	screen_state.input_busy = 0

func draw_debug_lines():
	var d1 = temp_pos.x
	var d2 = temp_pos.y
	var d3 = screen_state.grid_size.x - temp_pos.x
	var d4 = screen_state.grid_size.y - temp_pos.y
	
	$Line2D.visible = true
	$Line2D2.visible = true
	
	if d1 < 0 and d2 < 0:
		# TOP LEFT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(0, screen_state.grid_size.y)) - position]
	elif d1 >= 0 and d1 <= screen_state.grid_size.x and d2 < 0:
		# TOP
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(0, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, 0)) - position]
	elif d1 > screen_state.grid_size.x and d2 < 0:
		# TOP RIGHT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(0, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, screen_state.grid_size.y)) - position]	
	elif d1 > screen_state.grid_size.x and d2 > 0 and d2 < screen_state.grid_size.y:
		# RIGHT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, screen_state.grid_size.y)) - position]
	elif d1 > screen_state.grid_size.x and d2 > screen_state.grid_size.y:
		# BOTTOM RIGHT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(0, screen_state.grid_size.y)) - position]
	elif d1 > 0 and d1 < screen_state.grid_size.x and d2 > screen_state.grid_size.y:
		# BOTTOM
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, screen_state.grid_size.y)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(0, screen_state.grid_size.y)) - position]
	elif d1 < 0 and d2 > screen_state.grid_size.y:
		# BOTTOM LEFT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(0, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(screen_state.grid_size.x, screen_state.grid_size.y)) - position]
	elif d1 < 0 and d2 > 0 and d2 < screen_state.grid_size.y:
		#LEFT
		$Line2D.points = [Vector2(0, 0), convert_to_screen(Vector2(0, 0)) - position]
		$Line2D2.points = [Vector2(0, 0), convert_to_screen(Vector2(0, screen_state.grid_size.y)) - position]
	else:
		$Line2D.visible = false
		$Line2D2.visible = false

