extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const Native = preload("res://addons/godot-screengrab/screengrab.gdns")
var screengrab = Native.new()
var tex
var id
var window_atoms
var modal_flags = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	var file = File.new()
	file.open(OverlayManager.exec_dir+'/windows.json', File.READ)
	window_atoms = parse_json(file.get_as_text())
	file.close()
	

func create_texture():
	if not tex:
		tex = ExternalTexture.new()
		id = tex.get_external_texture_id()
		screengrab.update_texture(id)
	return tex
func set_key_state(key, pressed):
	screengrab.set_key_state(key, pressed)

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

var press_x = -999
var press_y = -999
var last_x = -999
var last_y = -999
var last_pressed = 0

func input_func(event):
	if event is InputEventMouseMotion && (!last_pressed||abs(event.position.x - press_x)+abs(event.position.y - press_y) > 55):
		if abs(last_x - event.position.x) + abs(last_y - event.position.y) > 4 || last_pressed:
			OverlayManager.desktop_active = true
			OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
			last_x = event.position.x
			last_y = event.position.y
	if event is InputEventMouseButton:
		OverlayManager.keyboard_target = ScreenGrab
		#print(event.position.x)
		if abs(event.position.x - press_x)+abs(event.position.y - press_y) > 100:
			OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
		#print(event.pressed)
		var state
		if event.pressed:
			state = 'mousedown'
		else:
			state = 'mouseup'
		if !last_pressed && event.pressed:
			press_x = event.position.x
			press_y = event.position.y
		last_pressed = event.pressed
		#print('xdotool', state, 1)
		OS.execute('xdotool',[state, '1'])


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
