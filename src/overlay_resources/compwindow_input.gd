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

func set_key_state(key, pressed):
	get_parent().compwindow.set_key_state(key, pressed)
func send_scroll(up, count):
	var i = 0
	var b
	if up:
		b = 0x8
	else:
		b = 0x10
	while i < count:
		get_parent().compwindow.window_update_mouse(b, 3, last_x, last_y - 40)
		get_parent().compwindow.window_update_mouse(0, 3, last_x, last_y - 40)
		i = i+1

func _input(event):
	if !get_parent().compwindow.get_id():
		return
	if event is InputEventMouseMotion && (!last_pressed||abs(event.position.x - press_x)+abs(event.position.y - press_y) > 55):
		if abs(last_x - event.position.x) + abs(last_y - event.position.y) > 4 || last_pressed:
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
			if event.position.y > 40:
				get_parent().compwindow.window_update_mouse(0xFF, 3, event.position.x, event.position.y - 40)
			last_x = event.position.x
			last_y = event.position.y
	if event is InputEventMouseButton:
		OverlayManager.keyboard_target = self
		#print(event.position.x)
		#if abs(event.position.x - press_x)+abs(event.position.y - press_y) > 100:
		
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
		#print(event.pressed)
		var state
		if event.pressed:
			state = 1
		else:
			state = 0
		if event.position.y > 40:
			get_parent().compwindow.window_update_mouse(state, 3, event.position.x, event.position.y - 40)
		if !last_pressed && event.pressed:
			press_x = event.position.x
			press_y = event.position.y
		last_pressed = event.pressed
		#print('xdotool', state, 1)
		#OS.execute('xdotool',[state, '1'])
