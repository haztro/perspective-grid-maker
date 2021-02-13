extends WindowDialog

signal update_tooltip(value)

onready var screen_state = get_node("/root/ScreenState")

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

func _on_Tween_tween_completed(object, key):
	if !is_open:
		visible = false

func _on_Button_pressed():
	close()

func _on_CheckBox_toggled(button_pressed):
	emit_signal("update_tooltip", button_pressed)
