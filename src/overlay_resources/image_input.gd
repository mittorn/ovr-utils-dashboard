extends TextureRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var press_x = -999
var press_y = -999
var last_x = -999
var last_y = -999
var last_pressed = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _input(event):
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
