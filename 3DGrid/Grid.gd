extends Spatial

onready var screen_state = get_node("/root/ScreenState")

var fog_distance = 0
var global_grid_spacing = 5
var use_global_grid_spacing = 0
var min_spacing = 0.05
var tilt_value = 0
var float_cube = 0 
var slice_angle = 0.1
var last_slice = 0
var last_rot = 0
var last_tilt_rot = 0

var yaw = 0
var pitch = 0
var sensitivity = 0.002

var cube_size = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	$Cube.scale = Vector3(cube_size, cube_size, cube_size)
	manage_planes(0, 0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
	
func rotate_grid(motion):
	yaw += motion.x * sensitivity 
	pitch = clamp(pitch + motion.y * sensitivity, -PI/2, PI/2)
	manage_planes(-pitch, yaw, motion.x * sensitivity);
	set_axis_rotation(Vector3(1, 0, 0), pitch)
	rotate(get_global_transform().basis.y, -motion.x * sensitivity)

func set_global_grid_spacing(val):
	global_grid_spacing = val
	$XLines.grid_spacing = val
	$XLinesUp.grid_spacing = val
	$YLines.grid_spacing = val
	$YLinesUp.grid_spacing = val
	$ZLines.grid_spacing = val
	$ZLinesH.grid_spacing = val
	redraw_all()
	
func isolate_visibility(line):
	for c in get_children():
		c.visible = false
		
	if line == "x":
		$XLines.visible = true
		$XLinesUp.visible = true
	elif line == "y":
		$YLines.visible = true
		$YLinesUp.visible = true
	elif line == "z":
		$ZLines.visible = true
	elif line == "zy":
		$ZLinesH.visible = true
		
func check_visibility(line):
	if line == "x":
		return $XLines.visible
	elif line == "y":
		return $YLines.visible
	elif line == "z":
		return $ZLines.visible
	elif line == "zy":
		return $ZLinesH.visible
	
func redraw_all():
	$XLines.generate_x_lines()
	$XLines.draw_lines()
	$XLinesUp.generate_x_lines()
	$XLinesUp.draw_lines()
	$YLines.generate_x_lines()
	$YLines.draw_lines()
	$YLinesUp.generate_x_lines()
	$YLinesUp.draw_lines()
	$ZLines.generate_x_lines()
	$ZLines.draw_lines()
	$ZLinesH.generate_x_lines()
	$ZLinesH.draw_lines()
	
func set_axis_rotation(axis, rot):
	rotate(axis, -last_rot)
	rotate(axis, rot)
	last_rot = rot
	
func set_tilt_rotation(axis, rot):
	rotate(axis, -last_tilt_rot)
	rotate(axis, rot)
	last_tilt_rot = rot
	
func manage_planes(pitch, yaw, angle):

	var which_slice = -int(pitch / slice_angle)
	if which_slice == 0:
		$XLines.translation.y = -cube_size
		$YLines.translation.y = -cube_size
		$XLinesUp.translation.y = cube_size
		$YLinesUp.translation.y = cube_size
	if pitch <= 0:
		$XLines.translation.y = -cube_size
		$YLines.translation.y = -cube_size
		$XLinesUp.translation.y = -atan(pitch) + cube_size
		$YLinesUp.translation.y = -atan(pitch) + cube_size
	elif pitch > 0:
		$XLines.translation.y = cube_size
		$YLines.translation.y = cube_size
		$XLinesUp.translation.y = -atan(pitch) - cube_size
		$YLinesUp.translation.y = -atan(pitch) - cube_size

	$ZLines.rotate(Vector3(0, 1, 0), angle)
	$ZLinesH.rotate(Vector3(0, 1, 0), angle)
			
func set_cube_visibility(val):
	$Cube.visible = val

func tilt(value):
#	set_tilt_rotation(get_global_transform().basis.z, deg2rad(value))
#	var diff = value - tilt_value
#	tilt_value = value
	get_parent().get_node("Camera").set_rotation(Vector3(0, 0, deg2rad(value)))
#	rotate(get_global_transform().basis.z, 0.001)
