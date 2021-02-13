extends Control

onready var screen_state = get_node("/root/ScreenState")

var line_settings = preload("res://2DToolbox/2DLineSettings.tscn")
var vanishing_point = preload("res://2DGrid/VanishingPoint.tscn")
var line_source = preload("res://2DGrid/LineSource.tscn")
var hv_settings = preload("res://2DToolbox/HVSettings.tscn")
var v_source = preload("res://2DGrid/VGrid.tscn")
var h_source = preload("res://2DGrid/HGrid.tscn")

onready var v_settings = get_node("ScrollContainer/VBoxContainer/HideButton")
onready var h_settings = get_node("ScrollContainer/VBoxContainer/HideButton2")

var responsible = 0
var grid = null
var main = null

var point_id = 0

var points = {}
var current_selected = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")	
	
	
	v_settings.set_contents(hv_settings.instance())
	h_settings.set_contents(hv_settings.instance())
	
	var vs = v_source.instance()
	main.grid_viewport.add_child(vs)
	var hs = h_source.instance()
	main.grid_viewport.add_child(hs)
	
	v_settings.get_contents().set_line(vs)
	h_settings.get_contents().set_line(hs)

	_on_viewport_size_changed()

#	x_settings.set_contents(line_settings.instance())
		
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

func set_grid_with_tool():
	
	v_settings.get_contents().set_line_with_tool()
	h_settings.get_contents().set_line_with_tool()
	
	for k in points.keys():
		points[k].set_line_with_tool()

func _on_viewport_size_changed():
	var window_size = OS.get_window_size()
	rect_size.y = window_size.y
	rect_position = Vector2(window_size.x - rect_size.x, 0)

func check_for_mouse_over():
	if get_viewport().get_mouse_position().x > rect_position.x:
		return true
	return false

func update_selected():
	for k in points.keys():
		if k == current_selected:
			points[k].vp.get_node("TextureButton").modulate = Color(1.0, 1.0, 1.0, 1.0)
			points[k].visible = true
		else:
			points[k].vp.get_node("TextureButton").modulate = Color(132/255.0, 132/255.0, 132/255.0, 1.0)
			points[k].visible = false

func add_point():
	var ls = line_settings.instance()
	points[point_id] = ls
	current_selected = point_id
	$ScrollContainer/VBoxContainer.add_child(ls)
	
	var vp = vanishing_point.instance()
	vp.vp_id = point_id
	vp.toolbox = self
	var line_s = line_source.instance()
	vp.line_source = line_s
	ls.set_line(vp)
	point_id += 1
	
	update_selected()
	main.grid_viewport.add_child(line_s)
	main.get_node("UI").add_child(vp)
	main.get_node("UI").move_child(vp, max(0, main.screen_toolbox.get_position_in_parent() - 1))
	
func remove_point():
	if points.has(current_selected):
		points[current_selected].vp.line_source.queue_free()
		points[current_selected].vp.queue_free()
		points[current_selected].queue_free()
		points.erase(current_selected)
		current_selected = -1
		

func _on_Button_pressed():
	add_point()
	
func _on_Button2_pressed():
	remove_point()
