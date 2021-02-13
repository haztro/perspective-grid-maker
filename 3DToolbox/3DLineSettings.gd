extends VBoxContainer


var lines = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_lines(node):
	lines.append(node)
	set_colour($ColBox.get_colour())
	set_grid_spacing($DensBox.get_density())
	set_visible($HBoxContainer/CheckBox.pressed)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_lines_with_tool(ggsv, ggs):
	for l in lines:
		set_colour($ColBox.get_colour())
		set_visible($HBoxContainer/CheckBox.pressed)
		
		if ggsv:
			set_grid_spacing(ggs)
		else:
			set_grid_spacing($DensBox.get_density())

func set_colour(value):
	for l in lines:
		l.set_colour(value)
		
func set_grid_spacing(value):
	for l in lines:
		l.set_grid_spacing(value)
		
func set_visible(value):
	for l in lines:
		l.visible = value

func _on_ColBox_colour_changed(value):
	set_colour(value)

func _on_DensBox_density_changed(value):
	var val = 0.005 * pow(0.002, -value)
	set_grid_spacing(val)

func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		set_visible(true)
	else:
		set_visible(false)
