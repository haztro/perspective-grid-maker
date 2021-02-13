extends Tree


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var root = create_item()
	root.set_text(0, "Grid")
	var child1 = create_item(root)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
