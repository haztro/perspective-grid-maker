extends Node2D

onready var screen_state = get_node("/root/ScreenState")

var density = 50
var lines = []
var colour = Color(0, 0, 0, 1)

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for i in range(400):
		var l = Line2D.new()
		lines.append(l)
		add_child(l)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	draw_grid()

func draw_grid():
	var lines_drawn = 0
	
	for i in range(len(lines)):
		lines[i].visible = false
		if density != 0 and lines_drawn <= density:
			var pos = Vector2(0, 0)
			if screen_state.exporting:
				lines[i].width = 0.1
			else:
				lines[i].width = max(1, screen_state.main_camera_zoom.x)
			lines[i].default_color = colour
			lines[i].antialiased = true
			lines[i].points = [Vector2(0, screen_state.grid_size.y * lines_drawn/density) - pos, Vector2(screen_state.grid_size.x, screen_state.grid_size.y * lines_drawn/density) - pos]
			lines[i].visible = true
			lines_drawn += 1	
