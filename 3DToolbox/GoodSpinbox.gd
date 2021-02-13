extends Control

signal value_changed(value)

export var max_value = 100
export var min_value = 0
export var step = 1
export var value = 0

var direction = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$LineEdit.text = str(value)

func set_value(val):
	if val >= max_value:
		value = max_value
	elif val <= min_value:
		value = min_value
	else:
		value = val
	emit_signal("value_changed", value)
	$LineEdit.text = str(int(value))
	
func set_value_keep_text(val):
	if val >= max_value:
		value = max_value
	elif val <= min_value:
		value = min_value
	else:
		value = val

func change_value(dir):
	value += step * dir
	if value >= max_value:
		value = max_value
	elif value <= min_value:
		value = min_value
	emit_signal("value_changed", value)
	$LineEdit.text = str(int(value))

func _on_TextureButton_button_down():
	change_value(1)
	direction = 1
	$DelayTimer.start()

func _on_TextureButton_button_up():
	$Timer.stop()
	$DelayTimer.stop()

func _on_TextureButton2_button_down():
	change_value(-1)
	direction = -1
	$DelayTimer.start()

func _on_TextureButton2_button_up():
	$Timer.stop()
	$DelayTimer.stop()

func _on_Timer_timeout():
	change_value(direction)
	$LineEdit.text = str(int(value))
	
func _on_DelayTimer_timeout():
	$Timer.start()

func _on_LineEdit_text_changed(new_text):
	if new_text.is_valid_integer():
		set_value_keep_text(int(new_text))
		emit_signal("value_changed", int(new_text))
#		$LineEdit.text = new_text
			
func _on_LineEdit_text_entered(new_text):
	if new_text.is_valid_integer():
		set_value(int(new_text))
	else:
		$LineEdit.text = str(int(value))


func _on_LineEdit_focus_exited():
	$LineEdit.text = str(int(value))
