extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var prev_x = 0
var prev_y = 0
var x_delta = 0
var y_delta = 0

func _physics_process(delta):
	if OverlayInteractionRoot.gi:
		return
	var x = get_parent().get_joystick_axis(0)
	var y = get_parent().get_joystick_axis(1)
	if x > 0 && x > prev_x:
		x_delta += x - prev_x
	if x > 0.9:
		x_delta += 0.05
	if x < 0 && x < prev_x:
		x_delta += x - prev_x
	if x < -0.9:
		x_delta -= 0.05
	prev_x = x
	if y > 0 && y > prev_y:
		y_delta += y - prev_y
	if y > 0.9:
		y_delta += 0.05
	if y < 0 && y < prev_y:
		y_delta += y - prev_y
	if y < -0.9:
		y_delta -= 0.05
	prev_y = y
	if x_delta > 0.2:
		OS.execute('xdotool',['key', 'Right'])
		x_delta = 0
		y_delta = 0
	if x_delta < -0.2:
		OS.execute('xdotool',['key', 'Left'])
		x_delta = 0
		y_delta = 0
	if y_delta > 0.5:
		OS.execute('xdotool',['key', 'Up'])
		y_delta = 0
		x_delta = 0
	if y_delta < -0.5:
		OS.execute('xdotool',['key', 'Down'])
		y_delta = 0
		x_delta = 0
	if x == 0:
		x_delta = 0
	if y == 0:
		y_delta = 0
	#print(x_delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
