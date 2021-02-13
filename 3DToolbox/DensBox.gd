extends VBoxContainer


signal density_changed(value)

export var min_value = 0.01
export var max_value = 5
export var step = 0.01
export var value = 0.5

var init_complete = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$MarginContainer/HSlider.min_value = min_value
	$MarginContainer/HSlider.max_value = max_value
	$MarginContainer/HSlider.step = step
	$MarginContainer/HSlider.value = value
	$Label.text = "Grid Space: " + str(value)
	init_complete = 1
	
func get_density():
	return $MarginContainer/HSlider.value
	
func set_density(val):
	$MarginContainer/HSlider.value = val

func _on_HSlider_value_changed(value):
	if init_complete:
		$Label.text = "Grid Space: " + str(value)
		emit_signal("density_changed", value)

