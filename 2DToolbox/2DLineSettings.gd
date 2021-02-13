extends Control


var vp = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func set_tooltip(value):
	for c in get_children():
		c.set_tooltip_enabled

func set_line(node):
	vp = node
	vp.settings = self
	set_visible($HBoxContainer/CheckBox.pressed)
#	set_vp_position($SizeBox.get_size_value())
	set_colour($ColBox.get_colour())
	set_grid_spacing($DensBox2D.get_density())
	
func set_line_with_tool():
	set_visible($HBoxContainer/CheckBox.pressed)
	set_vp_position($SizeBox.get_size_value())
	set_colour($ColBox.get_colour())
	set_grid_spacing($DensBox2D.get_density())
	
func set_visible(val):
	vp.set_visible(val)
	
func set_vp_position(val):
	vp.set_vp_position(val)
	
func set_colour(val):
	vp.set_colour(val)
	
func set_grid_spacing(val):
	vp.set_grid_spacing(val)
	
func set_size_box_with_vp(val):
	$SizeBox.set_size_value(val)

func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		set_visible(true)
	else:
		set_visible(false)
		
func _on_ColBox_colour_changed(value):
	set_colour(value)

func _on_SizeBox_value_changed(value):
	set_vp_position(value)

func _on_CheckBox2_toggled(button_pressed):
	vp.set_locked(button_pressed)

func _on_DensBox2D_density_changed(value):
	set_grid_spacing(value)
