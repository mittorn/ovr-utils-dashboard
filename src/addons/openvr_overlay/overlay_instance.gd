extends Spatial

#signal path_changed
signal overlay_visible_changed
signal overlay_visible_changed2
signal width_changed
signal alpha_changed
signal target_changed
signal fallback_changed
signal offset_changed
signal compwindow_changed

const TARGETS = ["head", "left", "right", "world"]
export (String,  "head", "left", "right", "world") var target = "left" setget set_target

export var width_meters := 0.4 setget set_width_in_meters
export var alpha        := 1.0 setget set_alpha
export var compwindow_index = 0
export var compwindow_class = 0
var _tracker_id := 0
var _offsets:Dictionary = {
	"head":  {"pos": Vector3(0, 0, -0.35), "rot": Quat()},
	"left":  {"pos": Vector3(), "rot": Quat()},
	"right": {"pos": Vector3(), "rot": Quat()},
	"world": {"pos": Vector3(0,1,0), "rot": Quat()},
}

# what's actually tracking
var current_target: String = "world" setget _set_current_target
var fallback = ["left", "right", "head"] # TODO setget that updates tracking (not important)
var interaction_handler: Node
var overlay_visible := true setget set_overlay_visible
var path : String = "res://special_overlays/MainOverlay.tscn"# setget set_path
var path_invalid := false
var OVERLAY_PROPERTIES: Dictionary # defined in overlay root script (optional)

onready var container = $OverlayViewport/Container
var overlay_scene: Node

func _process(delta):
	#$VROverlayViewport.arvr = false
#	print('p')
	#$VROverlayViewport.set_override_size(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height)
	pass
	#$VROverlayViewport.set_override_size(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height)

func _ready() -> void:
	container = $OverlayViewport/Container
	load_overlay()
	current_target = target

	ARVRServer.connect("tracker_added", self, "_tracker_changed")
	ARVRServer.connect("tracker_removed", self, "_tracker_changed")
	if not "width" in OVERLAY_PROPERTIES:
		OVERLAY_PROPERTIES.width = 1024
	if not "height" in OVERLAY_PROPERTIES:
		OVERLAY_PROPERTIES.height = 1024

	$OverlayViewport.size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	#$VROverlayViewport.set_size_override(true, Vector2(64, 64))
	#$VROverlayViewport.set_override_size(64, 64)
	#$VROverlayViewport.arvr = false
	$VROverlayViewport.size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	# OverlayInit.ovr_interface.get_render_targetsize()
	#Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	
	$VROverlayViewport/TextureRect.rect_size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height) #OverlayInit.ovr_interface.get_render_targetsize() / 2
	#Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	#OverlayInit.ovr_interface.get_render_targetsize()
	set_notify_transform(true)

	update_tracker_id()
	call_deferred("update_offset")
	add_to_group("overlays")

func try_update_size():

	$OverlayViewport.size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	#$VROverlayViewport.set_size_override(true, Vector2(64, 64))
	#$VROverlayViewport.set_override_size(64, 64)
	#$VROverlayViewport.arvr = false
	$VROverlayViewport.size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	update_tracker_id()
	$VROverlayViewport/TextureRect.rect_size = Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height) #OverlayInit.ovr_interface.get_render_targetsize() / 2
	# OverlayInit.ovr_interface.get_render_targetsize()
	#Vector2(OVERLAY_PROPERTIES.width, OVERLAY_PROPERTIES.height);
	emit_signal("width_changed")
	


func load_overlay() -> void:
	path_invalid = false

	var packed_overlay = load(path)
	if not packed_overlay:
		path_invalid = true
		overlay_scene = load("res://special_overlays/UnknownType.tscn").instance()
	else:
		overlay_scene = packed_overlay.instance()

	if overlay_scene.has_method("pre_prop_callback"):
		overlay_scene.pre_prop_callback(self)

	if overlay_scene.get("OVERLAY_PROPERTIES") != null:
		OVERLAY_PROPERTIES = overlay_scene.OVERLAY_PROPERTIES

	$OverlayInteraction.spawn_modules()

	if container.get_child_count() > 0:
		container.get_child(0).queue_free()
	container.add_child(overlay_scene)
	$VROverlayViewport.set_overlay_flag(1 << 16, true)
	#if(name == 'MainOverlay'):
	

func update_tracker_id():
	_tracker_id = -1
	match current_target:
		"left":
			_tracker_id = OverlayInit.trackers.left
		"right":
			_tracker_id = OverlayInit.trackers.right
		_:
			return

	if _tracker_id == -1:
		# could not find controller, fallback
#		print("Missing controller ", current_target, " ", target, " ", fallback, " - ", name)
		_tracker_id = 63 # highest tracker id (unused, at origin)

var hided_after_launch = false
func update_offset():
	translation = _offsets[current_target].pos
	transform.basis = Basis(_offsets[current_target].rot)

	match current_target:
		"head":
			$VROverlayViewport.track_relative_to_device(0, global_transform)
		"world":
			#print('world',OverlayInteractionRoot.world_transform.origin)
			#translation += OverlayInteractionRoot.world_transform.origin
			#transform *= OverlayInteractionRoot.world_transform #.basis = Basis(_offsets[current_target].rot * Quat(OverlayInteractionRoot.world_transform.basis) )
			#translation = OverlayInteractionRoot.world_transform.xform(translation)
			$VROverlayViewport.overlay_position_absolute(OverlayInteractionRoot.world_transform * transform)
		_:
			$VROverlayViewport.track_relative_to_device(_tracker_id, global_transform)
	if(name == 'MainOverlay') && !hided_after_launch:
		silently_hide(true)
		hided_after_launch = true


func update_current_target():
	if OverlayInit.trackers[target] != -1:
		_set_current_target(target)
	else: # fallback if not found
		for f in fallback:
			if OverlayInit.trackers[f] != -1:
				_set_current_target(f)
				break
	update_tracker_id()

func silently_hide(hide: bool):
	if hide:
		$VROverlayViewport.overlay_visible = false
		emit_signal("overlay_visible_changed2", false)
	else:
		$VROverlayViewport.overlay_visible = overlay_visible
		emit_signal("overlay_visible_changed2", overlay_visible)

func set_overlay_visible(state: bool):
	overlay_visible = state
	
	$VROverlayViewport.overlay_visible = state
	emit_signal("overlay_visible_changed", state)

func currently_visible() -> bool:
	return $VROverlayViewport.overlay_visible

func _tracker_changed(tracker_name: String, type: int, id: int):
	update_current_target()
	update_offset()


func set_target(new: String):
	target = new
	call_deferred("update_offset")
	update_current_target()


func _set_current_target(new: String): # overrides target
	current_target = new
	update_tracker_id()
	update_offset()
	emit_signal("target_changed")

func update_pos():
	update_tracker_id()
	update_offset()
	emit_signal("target_changed")


func get_offset(offset_target: String) -> Dictionary:
	var o =  _offsets[offset_target].duplicate()
	#if offset_target == 'world':
		#o.pos -= OverlayInteractionRoot.world_transform.origin
		#o.pos = OverlayInteractionRoot.world_transform.xform_inv(o.pos)
		#o.rot *= Quat(OverlayInteractionRoot.world_transform.basis) #.inverse() 
	return o


func set_offset(offset_target: String, pos: Vector3, rot: Quat) -> void:
	#if offset_target == 'world':
	#	_offsets[offset_target].pos = OverlayInteractionRoot.world_transform.xform_inv(pos)#pos - OverlayInteractionRoot.world_transform.origin
	#	_offsets[offset_target].rot = rot #* Quat(OverlayInteractionRoot.world_transform.basis).inverse() 
	#else:
	_offsets[offset_target].pos = pos
	_offsets[offset_target].rot = rot
	update_offset()


func set_width_in_meters(width: float) -> void:
	width_meters = width
	$VROverlayViewport.overlay_width_in_meters = width_meters
	emit_signal("width_changed")

func enter_ghost_mode():
	if name.find('Keyboard'):
		pass
	else:
		silently_hide(true)
	$VROverlayViewport/TextureRect.modulate.a = alpha * 0.5
func exit_ghost_mode():
	if name.find('Keyboard'):
		pass
	else:
		silently_hide(false)
	$VROverlayViewport/TextureRect.modulate.a = alpha

func set_alpha(val: float):
	alpha = val
	$VROverlayViewport/TextureRect.modulate.a = val
	emit_signal("alpha_changed")

func set_flag(flag: int, enabled: bool):
	$VROverlayViewport.set_overlay_flag(flag, enabled)


func reset_offset() -> void:
	_offsets[current_target].rot = Quat()
	_offsets[current_target].pos = Vector3()
	if current_target == "head" || current_target == "world":
		_offsets[current_target].pos.z = -0.5
	update_offset()


func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		emit_signal("offset_changed")


func get_property(p_name: String):
	if OVERLAY_PROPERTIES.has(p_name):
		return OVERLAY_PROPERTIES[p_name]

	return OverlayInit.OVERLAY_PROPERTIES_DEFAULT[p_name]
