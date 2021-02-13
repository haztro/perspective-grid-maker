extends WindowDialog


onready var screen_state = get_node("/root/ScreenState")

signal new_grid(mode, size)

var mode = 1
var is_open = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	var dialog_nodes = get_children()
	for node in dialog_nodes:
		if (node is TextureButton):
			node.hide()	

	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	rect_pivot_offset = $PanelContainer.rect_size / 2
	rect_position = OS.get_window_size() / 2 - $PanelContainer.rect_size / 2

func _on_viewport_size_changed():
	rect_position = OS.get_window_size() / 2 - $PanelContainer.rect_size / 2

func _input(event):
	if event.is_action_pressed("esc") and is_open:
		get_tree().set_input_as_handled()
		close()
		
func open():
	show()
	visible = true
	is_open = true
	screen_state.window_open += 1
	var window_size = OS.get_window_size()
	var scale_max = Vector2(1, 1)
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", Vector2(0, 0), scale_max, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	
func close():
	screen_state.window_open -= 1
	is_open = false
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Button_pressed():
	close()

func _on_Button2_pressed():
	close()
	emit_signal("new_grid", mode, $PanelContainer/VBoxContainer/SizeBox.get_size_value())

func _on_CheckBox_pressed():
	if !$PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/CheckBox.pressed:
		$PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/CheckBox.pressed = 1
		$PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/CheckBox2.pressed = 0
	else:
		$PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/CheckBox2.pressed = 0
	mode = 1
		
func _on_CheckBox2_pressed():
	if !$PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/CheckBox2.pressed:
		$PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer2/CheckBox2.pressed = 1
		$PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/CheckBox.pressed = 0
	else:
		$PanelContainer/VBoxContainer/VBoxContainer/HBoxContainer/CheckBox.pressed = 0
	mode = 0

func _on_Tween_tween_completed(object, key):
	if !is_open:
		visible = false
