extends Control

onready var screen_state = get_node("/root/ScreenState")
onready var x_settings = get_node("ScrollContainer/VBoxContainer/VBoxContainer4/HideButton")
onready var y_settings = get_node("ScrollContainer/VBoxContainer/VBoxContainer4/HideButton2")
onready var z_settings = get_node("ScrollContainer/VBoxContainer/VBoxContainer4/HideButton3")
onready var hz_settings = get_node("ScrollContainer/VBoxContainer/VBoxContainer4/HideButton4")

var line_settings = preload("res://3DToolbox/3DLineSettings.tscn")

var responsible = 0
var grid = null
var main = null

var c_fov = 50
var c_fovx = 120

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	
	x_settings.set_contents(line_settings.instance())
	y_settings.set_contents(line_settings.instance())
	z_settings.set_contents(line_settings.instance())
	hz_settings.set_contents(line_settings.instance())
	
	_on_viewport_size_changed()
		
func _process(delta):
	
	if screen_state.window_open:
		$ColorRect.visible = true
	else:
		$ColorRect.visible = false
	
	if check_for_mouse_over():
		screen_state.input_busy = 1
		responsible = 1
	else:
		if responsible:
			screen_state.input_busy = 0
			responsible  = 0
			
func set_grid(value):
	grid = value
	x_settings.get_contents().set_lines(grid.get_node("XLines"))
	x_settings.get_contents().set_lines(grid.get_node("XLinesUp"))
	y_settings.get_contents().set_lines(grid.get_node("YLines"))
	y_settings.get_contents().set_lines(grid.get_node("YLinesUp"))
	z_settings.get_contents().set_lines(grid.get_node("ZLines"))
	hz_settings.get_contents().set_lines(grid.get_node("ZLinesH"))
	hz_settings.get_contents().set_visible(false)
	hz_settings.get_contents().get_node("HBoxContainer/CheckBox").pressed = false
	grid.fog_distance = 2 * pow(0.02, -$ScrollContainer/VBoxContainer/VBoxContainer/HSlider.value)
	
func set_grid_with_tool():
	x_settings.get_contents().set_lines_with_tool(grid.use_global_grid_spacing, grid.global_grid_spacing)
	y_settings.get_contents().set_lines_with_tool(grid.use_global_grid_spacing, grid.global_grid_spacing)
	z_settings.get_contents().set_lines_with_tool(grid.use_global_grid_spacing, grid.global_grid_spacing)
	hz_settings.get_contents().set_lines_with_tool(grid.use_global_grid_spacing, grid.global_grid_spacing)
	
func _on_viewport_size_changed():
	var window_size = OS.get_window_size()
	rect_size.y = window_size.y
	rect_position = Vector2(window_size.x - rect_size.x, 0)

func check_for_mouse_over():
	if get_viewport().get_mouse_position().x > rect_position.x:
		return true
	return false

func _on_HSlider_value_changed(value):
	grid.fog_distance = 2 * pow(0.02, -value)
	grid.redraw_all()

func _on_HSlider2_value_changed(value):
	if get_node("ScrollContainer/VBoxContainer/HBoxContainer3/CheckBox3").pressed:
		c_fovx = value
	else:
		c_fov = value
		
	main.grid_3d.get_parent().get_node("Camera").fov = c_fov
	main.grid_3d.get_parent().get_node("Camera").get_node("Camera360").fovx = c_fovx

func _on_CheckBox_toggled(button_pressed):
	grid.get_node("Cube").visible = button_pressed

func _on_CheckBox2_toggled(button_pressed):
	grid.use_global_grid_spacing = button_pressed
	grid.set_global_grid_spacing(grid.get_node("XLines").grid_spacing)

func _on_HSlider3_value_changed(value):
	$ScrollContainer/VBoxContainer/VBoxContainer3/Label.text = "Tilt: " + str(value) + " degrees"
	grid.tilt(value)

func _on_CheckBox3_toggled(button_pressed):
	if button_pressed:
		main.grid_viewport.get_node("Camera").get_node("Camera360").visible = true
		main.grid_viewport.get_node("Camera").get_node("Camera360").current = true
		main.grid_viewport.get_node("Camera").current = false
		
		get_node("ScrollContainer/VBoxContainer/VBoxContainer2/HSlider2").max_value = 358
		get_node("ScrollContainer/VBoxContainer/VBoxContainer2/HSlider2").value = c_fovx
	else:
		main.grid_viewport.get_node("Camera").get_node("Camera360").visible = false
		main.grid_viewport.get_node("Camera").get_node("Camera360").current = false
		main.grid_viewport.get_node("Camera").current = true
		get_node("ScrollContainer/VBoxContainer/VBoxContainer2/HSlider2").value = c_fov
		get_node("ScrollContainer/VBoxContainer/VBoxContainer2/HSlider2").max_value = 120
