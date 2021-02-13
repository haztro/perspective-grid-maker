extends Control

var ls = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func set_tooltip(value):
	for c in get_children():
		c.set_tooltip_enabled

func set_line(node):
	ls = node
	set_visible($HBoxContainer/CheckBox.pressed)
	set_colour($ColBox.get_colour())
	set_grid_spacing($DensBox2D.get_density())
	
func set_line_with_tool():
	set_visible($HBoxContainer/CheckBox.pressed)
	set_colour($ColBox.get_colour())
	set_grid_spacing($DensBox2D.get_density())
	
func set_visible(val):
	ls.visible = val
	
func set_colour(val):
	ls.colour = val
	
func set_grid_spacing(val):
	ls.density = val
	

func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		set_visible(true)
	else:
		set_visible(false)
		
func _on_ColBox_colour_changed(value):
	set_colour(value)

func _on_DensBox2D_density_changed(value):
	set_grid_spacing(value)
