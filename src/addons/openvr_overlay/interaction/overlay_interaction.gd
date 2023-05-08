extends Node


signal near_on    # a controller entered the near area (enable cursor and/or touch visualiser)
signal near_off   # a controller exited
signal touch_on
signal touch_off
signal trigger_on  # trigger pushed while touching
signal trigger_off # trigger released

var grab_mode := false setget set_grab_mode

# reference to the area node thats used for touch
var _overlay_area: Spatial# = preload("res://addons/openvr_overlay/interaction/OverlayArea.tscn").instance()
var _right_is_activator := false # this hand has a collider on it to trigger things on the overlay
var _left_is_activator  := false
var collision_pos := Vector3(0,0,0)

var pause_triggers := false # disable triggers updating (used by grab module)

var state := {
	"right": {
		"active": false,
		"near": false,
		"touch": false,
		"trigger": false,
		"laser" : false,
		"laser_pos" : Vector2(0,0)
	},
	"left": {
		"active": false,
		"near": false,
		"touch": false,
		"trigger": false,
		"laser": false,
		"laser_pos" : Vector2(0,0)
	},
}


onready var tracker_nodes = {
	"head":  $VR/head,
	"left":  $VR/left,
	"right": $VR/right,
	"world": $VR/world,
}


func _ready() -> void:
	_overlay_area = $OverlayArea
	var touch = $OverlayArea/AreaTouch
	#_overlay_area['parent'] = self
	touch.set_meta("parent",self)
	_overlay_area.get_node("AreaNear"). connect("area_entered", self, "_on_Near_entered")
	_overlay_area.get_node("AreaNear"). connect("area_exited",  self, "_on_Near_exited")
	_overlay_area.get_node("AreaTouch").connect("area_entered", self, "_on_Touch_entered")
	_overlay_area.get_node("AreaTouch").connect("area_exited",  self, "_on_Touch_exited")

	get_parent().connect("width_changed", self, "_update_width")
	get_parent().connect("offset_changed", self, "_update_offset")
	get_parent().connect("target_changed", self, "_update_target")
	get_parent().connect("overlay_visible_changed", self, "_update_vis")
	get_parent().connect("overlay_visible_changed2", self, "_update_vis")

	OverlayManager.connect("grab_mode_changed", self, "update_selection")

	call_deferred("_update_width")
	call_deferred("_update_offset")
	call_deferred("_update_target")


func _trigger_on(controller):
	if OverlayInteractionRoot.ignore_action || OverlayInteractionRoot.gi:
		return
	if controller == get_parent().current_target:
		return
	if state[controller].near || state[controller].laser:
		state[controller].trigger = true
#		print("TRIGGER ON ", controller)
		emit_signal("trigger_on", controller)

func _trigger_off(controller):
	if OverlayInteractionRoot.ignore_action:
		return
	state[controller].trigger = false
#	print("TRIGGER OFF ", controller)
	emit_signal("trigger_off", controller)


func _on_Near_entered(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	var hand = body.get_groups()[0]
	state[hand].near = true
	update_selection()
#	print("NEAR ON ", hand)
	emit_signal("near_on")


func _on_Near_exited(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	var hand = body.get_groups()[0]
	state[hand].near = false

#	print("NEAR OFF ", hand)
	update_selection()
	emit_signal("near_off")


func _on_Touch_entered(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	var hand = body.get_groups()[0]
	state[hand].touch = true
	update_selection()
#	print("TOUCH ON ", hand)
	emit_signal("touch_on", hand)


func _on_Touch_exited(body: Node) -> void:
	if pause_triggers or !get_parent().overlay_visible:
		return
	var hand = body.get_groups()[0]
	state[hand].touch = false
	update_selection()
#	print("TOUCH OFF ", hand)
	emit_signal("touch_off", hand)

func laser_enter(controller, point: Vector3):
	#print(point)
	var p = _overlay_area.global_transform.xform_inv(point)
	#print(p)
	state[controller].laser_pos = Vector2(p.x, p.y + (get_parent().OVERLAY_PROPERTIES.width-get_parent().OVERLAY_PROPERTIES.height)* 1.0 /get_parent().OVERLAY_PROPERTIES.width * get_parent().width_meters * 0.5 )# - 20.0/2048.0)
	state[controller].laser = (p.z > 0)

func laser_exit(controller):
	state[controller].laser = false

func update_selection():
	var sel = (Settings.s.grab_mode or grab_mode)
	sel = sel and (state.right.near or state.left.near)
	get_parent().get_node("OverlayViewport/Selected").visible = sel


func set_grab_mode(state: bool) -> void:
	grab_mode = state
	update_selection()

func _update_vis2(state: bool):
	print('vis2')
	_overlay_area.get_node("AreaTouch/CollisionShape").set_disabled(true)
	pass

func _update_vis(state: bool):
	print('vis')
	_overlay_area.get_node("AreaTouch/CollisionShape").set_disabled(!state)
	pass

func _update_width():
	tracker_nodes.world.transform = OverlayInteractionRoot.world_transform
	#var ratio = OverlayInit.ovr_interface.get_render_targetsize()
	var aspect = float(get_parent().OVERLAY_PROPERTIES.height) / get_parent().OVERLAY_PROPERTIES.width
	var extents = get_parent().width_meters * 0.5
	_overlay_area.get_node("AreaNear/CollisionShape").shape.set_extents(
		Vector3(extents, extents * aspect, 0.1))
	_overlay_area.get_node("AreaTouch/CollisionShape").shape.set_extents(
		Vector3(extents, extents * aspect, 0.01))
	#_overlay_area.get_node("AreaTouch").translation.y = extents * (1 - aspect) #* aspect
	#_overlay_area.get_node("AreaNear").translation.y = extents * (1 - aspect) #* aspect


func _update_offset():
	
	var aspect = float(get_parent().OVERLAY_PROPERTIES.height) / get_parent().OVERLAY_PROPERTIES.width
	tracker_nodes.world.transform = OverlayInteractionRoot.world_transform
	_overlay_area.translation = get_parent().translation
	#_overlay_area.translation.y += (1-aspect)*aspect
	_overlay_area.rotation = get_parent().rotation
	#_overlay_area.global_transform = _overlay_area.global_transform.scaled(Vector3(1,1.0/aspect,1))
	#_overlay_area.scale = Vector3(1,aspect,1)
	#_overlay_area.get_node("")
	#print(aspect)

func _update_target():
	tracker_nodes.world.transform = OverlayInteractionRoot.world_transform
	var t = get_parent().current_target
	# reparent _overlay_area
	_overlay_area.get_parent().remove_child(_overlay_area)
	tracker_nodes[t].add_child(_overlay_area)

	state.right.active = t != "right"
	state.left.active = t != "left"
	# make area only detect colliders of a different hand
	_overlay_area.get_node("AreaNear").collision_mask = int(t!="right")*2 # detect right hand
	_overlay_area.get_node("AreaNear").collision_mask += int(t!="left")*4 # detect left hand
	_overlay_area.get_node("AreaNear").collision_mask = int(t!="right")*8 # detect right hand
	_overlay_area.get_node("AreaNear").collision_mask += int(t!="left")*16 # detect left hand


# called by overlay_instance after properties are loaded and before overlay scene enters the tree
func spawn_modules():
	# grab module
	if get_parent().get_property("has_grab"):
		var module = preload("res://addons/openvr_overlay/OverlayGrab.tscn")
		add_child(module.instance())

	# cursor module
#	if get_parent().get_property("has_cursor"):
	var module1 = preload("res://addons/openvr_overlay/OverlayCursor.tscn")
	add_child(module1.instance())
	
	# cursor module
	if get_parent().get_property("has_touch"):
		var module = preload("res://addons/openvr_overlay/OverlayTouchCursor.tscn")
		add_child(module.instance())


func _on_RightHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and state.right.active:
		_trigger_on("right")


func _on_RightHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and state.right.trigger:
		_trigger_off("right")


func _on_LeftHand_button_pressed(button: int) -> void:
	if button == JOY_VR_TRIGGER and state.left.active:
		_trigger_on("left")


func _on_LeftHand_button_release(button: int) -> void:
	if button == JOY_VR_TRIGGER and state.left.trigger:
		 _trigger_off("left")
