extends Node2D

onready var screen_state = get_node("/root/ScreenState")

var density = 100
var colour = Color(0, 0, 0, 1)
var distance = 0
var max_len = 10000
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	position = screen_state.grid_size / 2
	for i in range(400):
		var l = Line2D.new()
		lines.append(l)
		add_child(l)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cast_lines()
#	pass
	
func _on_selected(pos):
	position = pos

# Cast num_lines lines out from the vanishing point
func cast_lines():

	var lines_drawn = 0
	var angle = 0
	
	for i in range(len(lines)):
		lines[i].visible = false
		if density != 0 and lines_drawn <= density:
			var dir = Vector2(cos(PI * i / density), sin(PI * i / density))
			var points = []
			var pos = position
			var end_point = Vector2(int(pos.x + dir.x * max_len), int(pos.y + dir.y * max_len))
#			pos -= dir * max_len
			var c1 = get_collision_point(pos.x, pos.y, end_point.x, end_point.y, 0, 0, 0, screen_state.grid_size.y)
			var c2 = get_collision_point(pos.x, pos.y, end_point.x, end_point.y, 0, 0, screen_state.grid_size.x, 0)
			var c3 = get_collision_point(pos.x, pos.y, end_point.x, end_point.y, 0, screen_state.grid_size.y, screen_state.grid_size.x, screen_state.grid_size.y)
			var c4 = get_collision_point(pos.x, pos.y, end_point.x, end_point.y, screen_state.grid_size.x, 0, screen_state.grid_size.x, screen_state.grid_size.y)

			if c1 != null and is_inside_rect(c1): points.append(c1)
			if c2 != null and is_inside_rect(c2): points.append(c2)
			if c3 != null and is_inside_rect(c3): points.append(c3)
			if c4 != null and is_inside_rect(c4): points.append(c4)
			
			if screen_state.exporting:
				lines[i].width = 0.1
			else:
				lines[i].width = max(1, screen_state.main_camera_zoom.x)
			lines[i].default_color = colour
			lines[i].antialiased = true

			if len(points) == 2:
				lines[i].points = [points[0] - pos, points[1] - pos]
				lines[i].visible = true
			elif len(points) == 4:
				if c1 == Vector2(0, 0):
					lines[i].points = [points[0] - pos, points[2] - pos]
				elif c2 == Vector2(screen_state.grid_size.x, 0):
					lines[i].points = [points[0] - pos, points[1] - pos]
				lines[i].visible = true
			else:
				if pos == Vector2(0, 0):
					lines[i].points = [points[0] - pos, points[2] - pos]
					lines[i].visible = true
				elif pos == Vector2(0, screen_state.grid_size.y):
					lines[i].points = [points[1] - pos, points[2] - pos]
					lines[i].visible = true
				elif pos == Vector2(screen_state.grid_size.x, 0):
					lines[i].points = [points[0] - pos, points[1] - pos]
					lines[i].visible = true
				elif pos == screen_state.grid_size:
					lines[i].points = [points[0] - pos, points[1] - pos]
					lines[i].visible = true
				
			lines_drawn += 1

# Get the position of an intersection between two points
func get_collision_point(x1, y1, x2, y2, x3, y3, x4, y4):
	var den = ((x1 - x2) * (y3 - y4) - (y1 - y2) * (x3 - x4))
	if den == 0:
		return null
		
	var t = ((x1 - x3) * (y3 - y4) - (y1 - y3) * (x3 - x4)) / den
	var u = -((x1 - x2) * (y1 - y3) - (y1 - y2) * (x1 - x3)) / den
	var p = null
	
	if t >= 0 and t <= 1:
		p = Vector2(x1 + t * (x2 - x1), y1 + t * (y2 - y1))
	if u >= 0 and u <= 1:
		p = Vector2(x3 + u * (x4 - x3), y3 + u * (y4 - y3))

	return p
		
# Check if point lies within the grid viewport
func is_inside_rect(point):
#	if point.x != 0 and point.x != screen_state.grid_size.x and point.y != 0 and point.y != screen_state.grid_size.y:
#		return false
	return point.x >= 0 and point.x <= screen_state.grid_size.x and point.y >= 0 and point.y <= screen_state.grid_size.y

	


