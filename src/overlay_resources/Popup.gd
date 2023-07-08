extends "res://overlay_resources/compwindow.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func find_window():
	var window = compwindow.register_window('','125829720', instance.compwindow_index)
	raise_flags = 0
	print(window)
	if !window:
		get_parent().get_parent().get_parent().overlay_visible = false
	return window

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
