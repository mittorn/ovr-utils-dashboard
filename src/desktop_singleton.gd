extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const Native = preload("res://addons/godot-screengrab/screengrab.gdns")
var screengrab = Native.new()
var tex
var id
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func create_texture():
	if not tex:
		tex = ExternalTexture.new()
		id = tex.get_external_texture_id()
		screengrab.update_texture(id)
	return tex
func set_key_state(key, pressed):
	get_parent().screengrab.set_key_state(key, pressed)

func set_mouse(button,pressed):
	var state
	if pressed:
		state = 'mousedown'
	else:
		state = 'mouseup'
	OS.execute('xdotool',[state, button])

func send_scroll(up, count):
	var b
	if up:
		b = 4
	else:
		b = 5
	OS.execute('xdotool',['click', '--repeat', count, '--delay', 0, b])

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
