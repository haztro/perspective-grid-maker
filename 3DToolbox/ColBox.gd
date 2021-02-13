extends VBoxContainer

onready var rect = get_node("MarginContainer/ColorRect")
onready var r_slider = get_node("HBoxContainer/HSlider")
onready var g_slider = get_node("HBoxContainer2/HSlider2")
onready var b_slider = get_node("HBoxContainer3/HSlider3")

signal colour_changed(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	set_colour(Color(0, 0, 0, 1))

func get_colour():
	return rect.modulate
	
func set_colour(colour):
	r_slider.value = colour.r
	g_slider.value = colour.g
	b_slider.value = colour.b
	rect.modulate = Color(colour.r, colour.g, colour.b)

## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	rect.modulate = Color(r_slider.value, g_slider.value, b_slider.value)


func _on_HSlider_value_changed(value):
	rect.modulate = Color(r_slider.value, g_slider.value, b_slider.value)
	emit_signal("colour_changed", get_colour())

func _on_HSlider2_value_changed(value):
	rect.modulate = Color(r_slider.value, g_slider.value, b_slider.value)
	emit_signal("colour_changed", get_colour())

func _on_HSlider3_value_changed(value):
	rect.modulate = Color(r_slider.value, g_slider.value, b_slider.value)
	emit_signal("colour_changed", get_colour())
