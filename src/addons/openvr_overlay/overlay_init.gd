extends Node


const OVERLAY_PROPERTIES_DEFAULT = {
	"allow_delete": true,
	"allow_hide": true,
#	"interaction": true,
	"has_cursor": false,
	"has_touch": false,
	"has_grab": true,
	"width": 1024,
	"height": 1024,
}

var ovr_interface: ARVRInterface
var ovr_config := preload("res://addons/godot-openvr/OpenVRConfig.gdns").new()

var trackers = {
	"head": 0,
	"left": -1,
	"right": -1,
	"world": 63,
}

func _init() -> void:
#	OS.window_minimized = true
	if OS.has_feature("editor"):
		OS.execute('killall',['ovr-utils.x86_64'])
	ovr_config.set_global_overlay_input(true)
	ovr_config.set_application_type(2) # Set to OVERLAY MODE
	ovr_config.set_tracking_universe(1) # Set to SEATED MODE = 0, STANDING MODE = 1, RAW MODE = 2

	# Find the OpenVR interface and initialise it
	ovr_interface = ARVRServer.find_interface("OpenVR")
	if ovr_interface and ovr_interface.initialize():
		print("OpenVR Initialized.")
		# make sure vsync is disabled or we'll be limited to 60fps
	OS.vsync_enabled = false

	# up our physics to 90fps to get in sync with our rendering
	Engine.iterations_per_second = 90
	Engine.target_fps = 90



func _ready() -> void:
	ARVRServer.connect("tracker_added", self, "_tracker_added")
	ARVRServer.connect("tracker_removed", self, "_tracker_removed")
	update_hand_ids()
	#Input.set_use_accumulated_input(true)
	

func _tracker_added(tracker_name: String, type: int, id: int):
	update_hand_ids()


func _tracker_removed(tracker_name: String, type: int, id: int):
	match id:
		1:
			trackers.left = -1
		2:
			trackers.right = -1


func update_hand_ids():
	trackers.left = -1
	trackers.right = -1
	for i in ARVRServer.get_tracker_count():
		var t = ARVRServer.get_tracker(i)
		var tracking_id = get_id(t)
		match t.get_hand():
			1:
				trackers.left = tracking_id
			2:
				trackers.right = tracking_id


static func get_id(tracker) -> int:
	return int(tracker.get_name().split("_")[-1])
