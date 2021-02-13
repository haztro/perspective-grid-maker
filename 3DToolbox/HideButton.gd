extends Control

onready var arrow = get_node("VBoxContainer/HBoxContainer/TextureRect")

var contents = null
export var label_name = "Grid"

var contents_visible = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/HBoxContainer/Label.text = label_name
	$TextureButton.rect_min_size.y = $VBoxContainer/HBoxContainer/Label.rect_size.y
	arrow.rect_min_size.y = $VBoxContainer/HBoxContainer.rect_size.y
	arrow.rect_min_size.x = arrow.rect_min_size.y * 8.0 / 10.0
	
func set_contents(node):
	contents = node
	contents.visible = false
	$VBoxContainer.add_child(contents)
	
func get_contents():
	return contents

func _on_TextureButton_pressed():
	if contents != null:
		contents_visible ^= 1
		if contents_visible:
			arrow.rect_rotation = 90
			arrow.rect_position = Vector2(arrow.rect_size.x, 1)
			contents.visible = true
		else:
			arrow.rect_rotation = 0
			arrow.rect_position = Vector2(0, 0)
			contents.visible = false
