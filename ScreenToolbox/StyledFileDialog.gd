extends FileDialog

onready var screen_state = get_node("/root/ScreenState")

# Add auto set the exclusive etc
# Auto connect hide signal

var tween = null
var is_open = false

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")	

	tween = Tween.new()
	add_child(tween)
	
	var dialog_nodes = get_children()
	for node in dialog_nodes:
		if (node is TextureButton):
			node.hide()
			
	current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS)
	
func _on_viewport_size_changed():
	rect_position = OS.get_window_size() / 2 - rect_size / 2

func _input(event):
	if event.is_action_pressed("esc") and is_open:
		get_tree().set_input_as_handled()
		hide()
	
func open():
	screen_state.window_open += 1
	rect_pivot_offset = Vector2(0, 0)
	popup_centered()
	rect_pivot_offset = rect_size / 2
	is_open = true
	var window_size = OS.get_window_size()
	var scale_max = Vector2(1, 1)
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 0), Color(1, 1, 1, 1), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_scale", Vector2(0, 0), scale_max, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
func close():
	is_open = false
	screen_state.window_open -= 1
	tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_scale", Vector2(1, 1), Vector2(0, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()

func _on_FileDialog_hide():
	if is_open:
		show()
		close()

func _on_FileDialog_confirmed():
	screen_state.window_open += 1
	show()
	close()
