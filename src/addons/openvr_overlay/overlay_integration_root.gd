extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var world_transform = Transform()
var was_centered = false

var hidden := 0
var rc1: RayCast
var rc2: RayCast
var last_coll
var last_col
# Called when the node enters the scene tree for the first time.
func _ready():
	rc1 = $VR/right/RayCast1
	rc2 = $VR/left/RayCast2
	#$VR.global_transform.origin += Vector3(0,10,0)
	#center_world()
	#call_deferred("center_world")
	pass # Replace with function body.

func center_world():
	#world_transform = $VR/head.global_transform
	var new_transform = Transform().rotated(Vector3(1,0,0),$VR/head.global_transform.basis.get_euler().x).rotated(Vector3(0,1,0), $VR/head.global_transform.basis.get_euler().y)
	new_transform.origin = $VR/head.global_transform.origin
	world_transform = new_transform
	#world_transform.rotated()
	print(world_transform.origin)
	get_tree().call_group("overlays","update_pos")
var menu_vis = false
func _on_left_button_pressed(button: int) -> void:
	if gi:
		return
	if(button != 1 || hidden >= 1):
		return
	#menu_vis = !menu_vis
	#OverlayManager.set_hide_menu(menu_vis)
	print('tg')
	OverlayManager.emit_signal("toggle_kb")
	#print(button)
	pass
#	if button == JOY_OCULUS_MENU:
#		get_tree().paused = false
var right_grip = false
func _on_right_button_pressed(button: int) -> void:
	if(button == 2):
		right_grip = true
	if gi:
		return
	print(button)
	if(hidden >= 1):
		return

	if(button == 14):
		OS.execute('xdotool',['mousedown', 2])
	if(button == 7):
		OS.execute('xdotool',['mousedown', 3])
	if(button == 1):
		menu_vis = !menu_vis
		OverlayManager.set_hide_menu(menu_vis)

	pass
func _on_right_button_release(button: int) -> void:
	if(button == 2):
		right_grip = false
	if gi:
		return

	if(button == 14):
		OS.execute('xdotool',['mouseup', 2])
	if(button == 7):
		OS.execute('xdotool',['mouseup', 3])


#	if button == JOY_OCULUS_MENU:
#		get_tree().paused = false


func _physics_process(delta):
	if(!was_centered):
		if !($VR/head.global_transform.origin):
			return
		center_world()
		was_centered = true
	rc2.force_raycast_update()
	var coll = rc2.get_collider()
	if coll:
		if last_coll && last_coll != coll:
			last_coll.laser_exit('left')
		var p = coll.get_meta('parent') 
		if p == null:
			return
		#print(p)
		#.get_parent().get_parent().get_parent()
		#if p is Node and not p is ARVROrigin:
		p.laser_enter('left',rc2.get_collision_point())
		last_coll = p
	else:
		if last_coll:
			last_coll.laser_exit('left')
		last_coll = null
	rc1.force_raycast_update()
	var col = rc1.get_collider()
	if col:
		if last_col && last_col != col:
			last_col.laser_exit('right')
		var p = col.get_meta('parent') 
		if p == null:
			return
		#print(p)
		#.get_parent().get_parent().get_parent()
		#if p is Node and not p is ARVROrigin:
		p.laser_enter('right',rc1.get_collision_point())
		last_col = p
	else:
		if last_col:
			last_col.laser_exit('right')
		last_col = null
# Called every frame. 'delta' is the elapsed time since the previous frame.
var paused_time = 0
var paused = false
func _process(delta):
	if(!paused):
		return
	paused_time += delta
	if paused_time > 5:
		Settings.force_save()
		if !OS.has_feature("editor"):
			get_tree().quit()
	#print($VR/right/RayCast1.get_collider())
	pass
var ignore_action = 0
var gi = false
var left_test = false
var right_test = false
func _on_left_action_release(action):
	print("aa",action, hidden)
	if ignore_action:
		ignore_action -= 1
		return
	if action == '/actions/godot/in/test':
		left_test = false
		""" && hidden < 1:
		OverlayInit.ovr_config.set_global_overlay_input(true)
		get_tree().call_group("overlays","exit_ghost_mode")
		gi = false
		"""
	else:
		OverlayInit.ovr_config.set_global_overlay_input(!(hidden >= 1))
		OverlayInit.ovr_config.set_global_overlay_input(!(hidden >= 1))
		OverlayInit.ovr_config.set_global_overlay_input(!(hidden >= 1))
func _on_left_action_pressed(action):
	print(action, hidden)
	if ignore_action:
		ignore_action -= 1
		return
	if action == '/actions/godot/in/test':
		left_test = true
	"""
	if action == '/actions/godot/in/test' && hidden < 1:
		OverlayInit.ovr_config.set_global_overlay_input(false)
		get_tree().call_group("overlays","enter_ghost_mode")
		ignore_action = 2
		gi = true
	"""
	#	center_world()
	if action != '/actions/godot/in/menu':
		return
	Settings.force_save()
	#if !OS.has_feature("editor"):
	get_tree().quit()
	return
	hidden+=1
	hidden %= 2
	paused = (hidden >= 1)
	get_tree().paused = paused
	paused_time = 0
	if hidden == 0:
		center_world()
	OverlayManager.set_hide_all(hidden >= 1)
	OverlayInit.ovr_config.set_global_overlay_input(!(hidden >= 1))
	OverlayManager.set_hide_menu(false)



func _on_right_action_released(action):
	print(action, hidden)
	if left_test&& right_test && right_grip &&hidden < 1:
		if !gi:
			OverlayInit.ovr_config.set_global_overlay_input(false)
			get_tree().call_group("overlays","enter_ghost_mode")
			OverlayManager.restore_gpu_freq()
			
			ignore_action = 1
			gi = true
		else:
			OverlayInit.ovr_config.set_global_overlay_input(true)
			get_tree().call_group("overlays","exit_ghost_mode")
			gi = false
	right_test = false
	if ignore_action:
		ignore_action -= 1
		return
	pass # Replace with function body.


func _on_right_action_pressed(action):
	#print(action, hidden)
	if ignore_action:
		ignore_action -= 1
		return
	right_test = true
	pass # Replace with function body.
