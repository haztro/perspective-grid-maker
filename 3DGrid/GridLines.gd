extends Spatial

onready var screen_state = get_node("/root/ScreenState")
onready var draw = get_node("Draw")

var grid_spacing = 5
var num_lines = 100
var colour = Color(0, 0, 0, 1)
var line_points = []
var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_x_lines()
	draw_lines()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func generate_x_lines():
	line_points = []
	
	var gs = grid_spacing
	num_lines = 2 * int(get_parent().fog_distance / grid_spacing)
	
	for y in range(num_lines + 1):
		if y % 2 == 0:
			line_points.append(Vector3(-num_lines * gs/2, y * gs - num_lines * gs/2, 0))
			line_points.append(Vector3(num_lines * gs/2, y * gs-num_lines * gs/2, 0))
		else:
			line_points.append(Vector3(num_lines * gs / 2, y * gs - num_lines * gs/2, 0))
			line_points.append(Vector3(-num_lines * gs / 2, y * gs - num_lines * gs/2, 0))

		if y == num_lines:
			if y % 2 == 0:
				line_points.append(Vector3(num_lines * gs/2, -num_lines * gs / 2, 0))
				line_points.append(Vector3(-num_lines * gs/2, -num_lines * gs / 2, 0))
				line_points.append(Vector3(-num_lines * gs/2, y * gs-num_lines * gs/2, 0))
			else:
				line_points.append(Vector3(-num_lines * gs/2, -num_lines * gs / 2, 0))
				line_points.append(Vector3(num_lines * gs/2, -num_lines * gs / 2, 0))
				line_points.append(Vector3(num_lines * gs/2, y * gs-num_lines * gs/2, 0))
			
func set_grid_spacing(val):
	grid_spacing = val
	# Don't need to redraw lines if usging global
	if get_parent().use_global_grid_spacing:
		num_lines = 2 * int(get_parent().fog_distance/ grid_spacing)
		get_parent().set_global_grid_spacing(val)
	else:
		generate_x_lines()
		draw_lines()
	
func set_colour(col):
	colour = col
	generate_x_lines()
	draw_lines()
			
func draw_lines():
	get_node("Draw").clear()
	get_node("Draw").begin(Mesh.PRIMITIVE_LINES, null) #1 = is an enum for draw line, null is for text
	get_node("Draw").set_color(colour)

	for i in range(line_points.size()):
		if i + 1 < line_points.size():
			var A = line_points[i]
			var B = line_points[i + 1]
			get_node("Draw").add_vertex(A)
			get_node("Draw").add_vertex(B)

	get_node("Draw").end()


