extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var press_x = -999
var press_y = -999
var last_x = -999
var last_y = -999
var last_pressed = 0
var keystate: int = 0
const keymods = {
	'SHIFT':0x1,
	'CAPSLOCK': 0x2,
	'CONTROL': 0x4,
	'ALT': 0x8,
	'SUPER': 0x40
}
# send caps with xtest
const ScreenGrab = preload("res://addons/godot-screengrab/screengrab.gdns")

var screengrab = ScreenGrab.new()
var repeat_key = ''
func set_key_state(key, pressed):
	if key in keymods:
		if pressed:
			keystate |= keymods[key]
		else:
			keystate &= ~keymods[key] & 0xFF
		if(key == 'CAPSLOCK'):
			screengrab.set_key_state(key, pressed)
	else:
		if !pressed:
			repeat_key = ''
		else:
			if len(key) == 1 || key == 'BACKSPACE':
				repeat_key = key
				repeat_next = repeat_time + 0.4
			
	get_parent().compwindow.set_key_state(key, pressed, keystate)
var repeat_time = 0
var repeat_next = 0
func _process(delta):
	repeat_time += delta
	if repeat_next < repeat_time && len(repeat_key):
		repeat_next = repeat_time + 0.05
		get_parent().compwindow.set_key_state(repeat_key, 1, keystate)

func set_mouse(button, clicked):
	var b = 0x100 << (button - 1)
	if !clicked:
		b = 0
	get_parent().compwindow.window_update_mouse(b | keystate, 3, last_x, last_y - 40)
	repeat_key = ''
func send_scroll(up, count):
	var i = 0
	var b
	if up:
		b = 4
	else:
		b = 5
	while i < count:
		set_mouse(b, true)
		set_mouse(b, false)
		i = i+1


func _input(event):
	if !get_parent().compwindow.get_id():
		return
	if event is InputEventMouseMotion && (!last_pressed||abs(event.position.x - press_x)+abs(event.position.y - press_y) > 55):
		if abs(last_x - event.position.x) + abs(last_y - event.position.y) > 4 || last_pressed:
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
			if event.position.y > 40:
				get_parent().compwindow.window_update_mouse(0xFF00 | keystate, 3, event.position.x, event.position.y - 40)
			last_x = event.position.x
			last_y = event.position.y
	if event is InputEventMouseButton:
		repeat_key = ''
		OverlayManager.keyboard_target = self
		#print(event.position.x)
		#if abs(event.position.x - press_x)+abs(event.position.y - press_y) > 100:
		
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
		#print(event.pressed)
		var state
		if event.pressed:
			state = 0x100
		else:
			state = 0
		if event.position.y > 40:
			get_parent().compwindow.window_update_mouse( state | keystate, 3, event.position.x, event.position.y - 40)
		if !last_pressed && event.pressed:
			press_x = event.position.x
			press_y = event.position.y
		last_pressed = event.pressed
		#print('xdotool', state, 1)
		#OS.execute('xdotool',[state, '1'])