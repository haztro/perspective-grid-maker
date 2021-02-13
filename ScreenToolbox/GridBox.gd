extends VBoxContainer


export var title_label = "Grid"

# Called when the node enters the scene tree for the first time.
func _ready():
	$HBoxContainer/Label.text = title_label + ":"


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		$VBoxContainer.visible = true
		$ColBox.visible = true
	else:
		$VBoxContainer.visible = false
		$ColBox.visible = false
