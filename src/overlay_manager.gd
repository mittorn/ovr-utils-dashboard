extends Node

signal added_overlay
signal removed_overlay
signal grab_mode_changed
signal toggle_kb

var loaded := false
var dashboard := false

func _init() -> void:
	Settings.connect("settings_loaded", self, "_load_overlays")


func _ready() -> void:
	randomize()
	restore_gpu_freq()


func _load_overlays():
	if loaded:
		return
	loaded = true
	print("Loading in overlays")
	for name in Settings.s.overlays:
		if not name == "MainOverlay":
			add_overlay(name)


func add_overlay(name):
	print("Adding overlay '", name, "'")
	var instance = preload("res://addons/openvr_overlay/OverlayInstance.tscn").instance()
	instance.name = name
	instance.path = Settings.s.overlays[name].path
	instance.add_child(preload("res://OverlaySettingsSync.tscn").instance())
	add_child(instance)
	emit_signal("added_overlay", name)


func create_overlay(path, name):
	Settings.s.overlays[name] = {}
	Settings.s.overlays[name].path = path
	add_overlay(name)


func remove_overlay(name):
	print("Removing overlay '", name, "'")
	var to_remove = get_node(name)
	if not to_remove:
		print("Could not remove overlay '", name, "'")
		return
	to_remove.queue_free()
	Settings.s.overlays.erase(name)
	emit_signal("removed_overlay", name)
func set_hide_menu(hide: bool):
	$MainOverlay.silently_hide(!hide)
	#if(hide):
	#	$MainOverlay.overlay.update_running_apps()
	#get_node("MainOverlay").set_overlay_visible(hide)

func set_hide_all(hide: bool):
	#OverlayInteractionRoot.center_world()
	for o in Settings.s.overlays:
		get_node(o).silently_hide(hide)
	OverlayInit.ovr_config.set_global_overlay_input(!hide) # && !dashboard)
var exec_dir = OS.get_executable_path().get_base_dir()

# workaround mesa resetting gpu power mode on every vr app launch, including dashboard
func restore_gpu_freq():
	OS.execute(exec_dir+'/setgpu.sh',[])

# removed feature
func run_dashboard(run: bool):
	if run:
		OS.execute(exec_dir+'/start-vrwebhelper.sh',[])
	else:
		OS.execute(exec_dir+'/stop-vrwebhelper.sh',[])
	dashboard = run
	OverlayInit.ovr_config.set_global_overlay_input(!run)
	

