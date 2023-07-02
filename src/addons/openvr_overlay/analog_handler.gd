extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var prev_value = 0
var scroll_delta = 0
var time_delta = 0
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _physics_process(delta):
	if OverlayInteractionRoot.gi:
		return
	time_delta += delta
	if !OverlayManager.keyboard_target:
		return

	var value = get_parent().get_joystick_axis(1)
	if value > 0 && value > prev_value:
		scroll_delta += value - prev_value
	if value > 0.9:
		scroll_delta += 0.3
	if value < 0 && value < prev_value:
		scroll_delta += value - prev_value
	if value < -0.9:
		scroll_delta -= 0.3
	prev_value = value
	if(time_delta < 0.05):
		return
	time_delta = 0
	if scroll_delta > 0.5:
		#OS.execute('xdotool',['click', '--repeat', round(scroll_delta/0.5), '--delay', 0, 4])
		OverlayManager.keyboard_target.send_scroll(true, round(scroll_delta/0.5));
		scroll_delta = 0
	if scroll_delta < -0.5:
		OverlayManager.keyboard_target.send_scroll(false, round(-scroll_delta/0.5));
		#OS.execute('xdotool',['click', '--repeat', round(-scroll_delta/0.5), '--delay', 0, 5])
		scroll_delta = 0
	#print(scroll_delta)

