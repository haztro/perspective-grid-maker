extends Node2D

onready var screen_state = get_node("/root/ScreenState")

var width = 5

# Called when the node enters the scene tree for the first time.
func _ready():
#	get_tree().root.connect("size_changed", self, "_on_viewport_size_changed")
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func update_width():
	width = max(5, screen_state.main_camera_zoom.x * 5)
	$top.width = width
	$bot.width = width
	$right.width = width
	$left.width = width

func _on_viewport_size_changed():
	update_width()
	var w = width
	$top.points = [Vector2(-w/2, 0), Vector2(screen_state.grid_size.x + w/2, 0)]
	$bot.points = [Vector2(-w/2, screen_state.grid_size.y), Vector2(screen_state.grid_size.x + w/2, screen_state.grid_size.y)]
	$right.points = [Vector2(screen_state.grid_size.x, -w/2), screen_state.grid_size + Vector2(0, w/2)]
	$left.points = [Vector2(0, -w/2), Vector2(0, screen_state.grid_size.y + w/2)]
	
