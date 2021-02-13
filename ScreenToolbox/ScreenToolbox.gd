extends PanelContainer


onready var screen_state = get_node("/root/ScreenState")

signal fit_to_window
signal update_tooltip(value)

var responsible = 0
var main = null

# Called when the node enters the scene tree for the first time.
func _ready():
	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	_on_viewport_size_changed()


func _on_viewport_size_changed():
	var window_size = OS.get_window_size()
	rect_size.y = window_size.y
	rect_position = Vector2(0, 0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
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
			
func _on_Button_pressed():
	if !$SaveGridDialog.is_open:
		$SaveGridDialog.open()

func check_for_mouse_over():
	if get_viewport().get_mouse_position().x < rect_size.x:
		return true
	return false

func set_size_visible(val):
	$ScrollContainer/VBoxContainer/SizeBox.visible = val
	$ScrollContainer/VBoxContainer/Button3.visible = true
	$ScrollContainer/VBoxContainer/Button.visible = true
	$ScrollContainer/VBoxContainer/Button2.visible = true

func set_size_box(val):
	$ScrollContainer/VBoxContainer/SizeBox.set_size_value(val)

func _on_Button3_pressed():
	$FileDialog.open()
	$FileDialog.invalidate()

func _on_NewGridDialog_new_grid(mode, size):
	main.make_new_grid(mode, size)

func _on_FileDialog_file_selected(path):
	var tex = ImageTexture.new()
	var img = Image.new()
	var err = img.load(path)
	if err == OK:
		tex.create_from_image(img)
		main.set_background(tex, img.get_size())

func _on_Button4_pressed():
	if !$NewGridDialog.is_open:
		$NewGridDialog.open()

func _on_SizeBox_value_changed(value):
	if main != null:
		main.resize_viewport(value)

func _on_Button2_pressed():
	emit_signal("fit_to_window")


func _on_Button5_pressed():
	if !$HelpDialog.is_open:
		$HelpDialog.open()


func _on_HelpDialog_update_tooltip(value):
	emit_signal("update_tooltip", value)
