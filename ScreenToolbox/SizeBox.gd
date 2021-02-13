extends VBoxContainer

signal value_changed(value)

export var title = "Size"
export var label_one = "Width"
export var label_two = "Height"
export var max_value = 100
export var min_value = 0
export var step = 1
export var value = 0
export var title_size = 20

var initialised = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	initialise()
	
func initialise():
	$Label.text = title
	$HBoxContainer/Label.text = label_one
	$HBoxContainer2/Label.text = label_two
	
	$HBoxContainer/GoodSpinbox.max_value = max_value
	$HBoxContainer/GoodSpinbox.min_value = min_value
	$HBoxContainer/GoodSpinbox.step = step
	$HBoxContainer/GoodSpinbox.value = value
	
	$HBoxContainer2/GoodSpinbox2.max_value = max_value
	$HBoxContainer2/GoodSpinbox2.min_value = min_value
	$HBoxContainer2/GoodSpinbox2.step = step
	$HBoxContainer2/GoodSpinbox2.value = value
	
	$HBoxContainer/GoodSpinbox.get_node("LineEdit").focus_next = $HBoxContainer2/GoodSpinbox2.get_node("LineEdit").get_path()
	$HBoxContainer/GoodSpinbox.get_node("LineEdit").focus_previous = $HBoxContainer2/GoodSpinbox2.get_node("LineEdit").get_path()
	$HBoxContainer2/GoodSpinbox2.get_node("LineEdit").focus_next = $HBoxContainer/GoodSpinbox.get_node("LineEdit").get_path()
	$HBoxContainer2/GoodSpinbox2.get_node("LineEdit").focus_previous = $HBoxContainer/GoodSpinbox.get_node("LineEdit").get_path()
	
	set_size_value(Vector2(value, value))
	$Label.get("custom_fonts/font").set_size(title_size)
	initialised = 1

func get_size_value():
	return Vector2($HBoxContainer/GoodSpinbox.value, $HBoxContainer2/GoodSpinbox2.value)
	
func set_size_value(val):
	$HBoxContainer/GoodSpinbox.set_value(val.x)
	$HBoxContainer2/GoodSpinbox2.set_value(val.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_GoodSpinbox_value_changed(value):
	if initialised:
		emit_signal("value_changed", get_size_value())


func _on_GoodSpinbox2_value_changed(value):
	if initialised:
		emit_signal("value_changed", get_size_value())
