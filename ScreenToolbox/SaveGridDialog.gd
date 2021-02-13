extends WindowDialog

onready var screen_state = get_node("/root/ScreenState")

var is_open = false
var main = null

var ok_with_overwrite = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	
	for node in get_children():
		if (node is TextureButton):
			node.hide()	
			
	if screen_state.trial:
		$PanelContainer/VBoxContainer/HBoxContainer2/Button2.disabled = true
		$PanelContainer/VBoxContainer/HBoxContainer2/Button2.hint_tooltip = "Available in full version."

	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
#	rect_size = $PanelContainer.rect_size
	rect_pivot_offset = $PanelContainer.rect_size / 2
	rect_position = OS.get_window_size() / 2 - $PanelContainer.rect_size / 2

func _on_viewport_size_changed():
	rect_position = OS.get_window_size() / 2 - $PanelContainer.rect_size / 2

func _on_Button2_pressed():
	var error = 0
	var err = 0
	
	var file_name = $PanelContainer/VBoxContainer/VBoxContainer/LineEdit.text.to_lower()
	if file_name == "":
		file_name = "gridlines"
	
	# Check valid location
	var file_location = $PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer/LineEdit.text
	error = check_file_location(file_location)

	# Check if files already exist
	if !error:
		var f = File.new()
		if $PanelContainer/VBoxContainer/VBoxContainer3/HBoxContainer/CheckBox.pressed:
			if !main.mode_2d:
				for l in ["x", "y", "z", "zy"]:		
					if main.grid_3d.check_visibility(l):
						if f.file_exists(file_location + "/" + file_name + "_" + l + ".png"):
							if !ok_with_overwrite:
								error = 2
			else:
				var count = 0
				for c in main.grid_viewport.get_children():
					if c.visible == true:
						if f.file_exists(file_location + "/" + file_name + "_" + str(count) + ".png"):
							if !ok_with_overwrite:
								error = 2
						count += 1
		else:
			if f.file_exists(file_location + "/" + file_name + ".png"):
				if !ok_with_overwrite:
					error = 2
	
	# Check if any gridlines are even visible for exporting
	if !error:
		var count = 0
		if !main.mode_2d:
			for l in ["x", "y", "z", "zy"]:		
				if main.grid_3d.check_visibility(l):
					count += 1
		else:
			for c in main.grid_viewport.get_children():
				if c.visible == true:
					count += 1
		if count == 0:
			error = 3
	
	if !error:
		err = main.save_grid($PanelContainer/VBoxContainer/VBoxContainer3/HBoxContainer/CheckBox.pressed, file_location, file_name)

	if error:
		export_error(error, err)
	else:
		ok_with_overwrite = 0
		close()
	
func check_file_location(file_location):
	var directory = Directory.new()
	if directory.dir_exists(file_location) and file_location != "":
		return 0
	return 1
	
	
func export_error(error, err):
	if error == 1:
		print("INVALID FILE LOCATION")
	elif error == 2:
		$ConfirmationDialog.open()
	elif error == 3:
		print("NO VISIBLE GRIDLINES")
	
	
func _on_ConfirmationDialog_confirmed():
	ok_with_overwrite = 1
	_on_Button2_pressed()

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
	is_open = false
	screen_state.window_open -= 1
	$Tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.interpolate_property(self, "rect_scale", rect_scale, Vector2(0, 0), 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()

func _on_Button_pressed():
	close()
	
func _on_Tween_tween_completed(object, key):
	if !is_open:
		visible = false

func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		$PanelContainer/VBoxContainer/VBoxContainer3/Label2.visible = true
	else:
		$PanelContainer/VBoxContainer/VBoxContainer3/Label2.visible = false
	$PanelContainer.set_size(Vector2(0, 0))

func _on_Button3_pressed():
	$FileDialog.open()
	$FileDialog.invalidate()


func _on_FileDialog_dir_selected(dir):
	$PanelContainer/VBoxContainer/VBoxContainer2/HBoxContainer/LineEdit.text = dir
