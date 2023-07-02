extends Node

export var is_touch := false

onready var viewport: Viewport = get_node("../../OverlayViewport")
onready var _i = get_parent()

var t = 0
var skip_keyboard = false

var cursor_pos := {
	"right": Vector2(),
	"left": Vector2(),
}
var prev_pos := {
	"right": Vector2(),
	"left": Vector2(),
}
var click := {
	"right": false,
	"left": false,
}
var active_side := ""

var cursor_nodes := {
	"right": preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance(),
	"left": preload("res://addons/openvr_overlay/interaction/Cursor.tscn").instance(),
}
var temp = 0
var tstate = true

func _ready() -> void:
	viewport.add_child(cursor_nodes.right)
	viewport.add_child(cursor_nodes.left)
	skip_keyboard = _i.get_parent().OVERLAY_PROPERTIES.get("skip_keyboard") != null
	if is_touch:
		get_parent().connect("touch_on", self, "_trigger_on")
		get_parent().connect("touch_off", self, "_trigger_off")
	else:
		get_parent().connect("trigger_on", self, "_trigger_on")
		get_parent().connect("trigger_off", self, "_trigger_off")
	

func _process(delta: float) -> void:
	var left_moved = true
	var right_moved = true
	if _i.state.left.laser:
		cursor_pos.left = get_canvas_pos(_i.state.left.laser_pos)
	elif _i.state.left.near:
		var controller_local_pos = _i._overlay_area.global_transform.xform_inv(\
		_i.tracker_nodes['left'].translation)
		var pos = Vector2(controller_local_pos.x, controller_local_pos.y)
		cursor_pos.left = get_canvas_pos(pos)
	else:
		right_moved = false
	if _i.state.right.laser:
		cursor_pos.right = get_canvas_pos(_i.state.right.laser_pos)
	elif _i.state.right.near:
		var controller_local_pos = _i._overlay_area.global_transform.xform_inv(\
		_i.tracker_nodes['right'].translation)
		var pos = Vector2(controller_local_pos.x, controller_local_pos.y)
		cursor_pos.right = get_canvas_pos(pos)
	else:
		left_moved = false
	_update_cursors()
	if !left_moved && !right_moved:
		return

	#_i.state.left.laser = false
	#_i.state.right.laser = false
	t += delta
	if t > 0.01:
		_send_move_event()
		t = 0
	prev_pos = cursor_pos.duplicate(true)
#	if is_touch:
#		temp += delta
#		if temp > 0.5:
#			temp = 0
#			var click_event = InputEventMouseButton.new()
#			click_event.position = Vector2(240, 340)
#			click_event.pressed = tstate
#			tstate = !tstate
#			click_event.button_index = 1
#			viewport.input(click_event)
#			print("SENT EVENT ", click_event.position, " -- ", click_event.pressed)
##			viewport.


#get canvas position of controller
func get_canvas_pos(pos: Vector2) -> Vector2:
	var overlay_size = viewport.size
	#Vector2(4096, 4096)
	# scale to pixels
	#pos.x *= overlay_size.x
	#pos.y *= overlay_size.y
	pos *= overlay_size.x
	#pos.y *= overlay_size.x/overlay_size.y
	pos /= _i.get_parent().width_meters
	# adjust to center
	pos.y *= -1
	pos.x += overlay_size.x * 0.5
	pos.y += overlay_size.x * 0.5
	return pos


func _update_cursors():
	cursor_nodes.right.visible = _i.state.right.near || _i.state.right.laser
	cursor_nodes.left.visible = _i.state.left.near || _i.state.left.laser
	cursor_nodes.right.rect_position = cursor_pos.right
	cursor_nodes.left.rect_position = cursor_pos.left


func _send_move_event():
	if not active_side:
		return# only send move events while a cursor is held down
	if not cursor_nodes[active_side].visible:
		return
	if !_i.get_parent().currently_visible():
		return
	var event = InputEventMouseMotion.new()
	event.position = cursor_pos[active_side]
	event.relative = cursor_pos[active_side] - prev_pos[active_side]
	event.speed = event.relative
	#if event.position.x == 2048 or event.position.y == 2048:
	#	return
	viewport.input(event)
func set_key_state(key, pressed):
	var key_event : InputEventKey = InputEventKey.new()
	key_event.scancode = OS.find_scancode_from_string(key)
	if !key_event.scancode:
		key_event.scancode = OS.find_scancode_from_string('KEY_'+key);
	else:
		if OS.is_scancode_unicode(key_event.scancode):
			key_event.unicode = key[0].to_ascii()[0]

	key_event.pressed = pressed
	viewport.input(key_event)
func send_scroll(up, count):
	pass

func _send_click_event(state: bool, controller: String):
	if click[controller] == state:
		return # already in that state
	if !_i.get_parent().currently_visible():
		return
	click[controller] = state
	_update_active_side()
	var click_event = InputEventMouseButton.new()
	click_event.position = cursor_pos[controller]
	click_event.pressed = state
	click_event.button_index = 1
	if state && !skip_keyboard:
		OverlayManager.keyboard_target = self
	viewport.input(click_event)
#	print("SENT EVENT ", click_event.position, " -- ", click_event.pressed)


func _trigger_on(controller):
	if click.right or click.left:
		return
	_send_click_event(true, controller)


func _trigger_off(controller):
	_send_click_event(false, controller)

func _update_active_side() -> void:
	if click.right:
		active_side = "right"
	elif click.left:
		active_side = "left"
#	else:
#		active_side = ""
