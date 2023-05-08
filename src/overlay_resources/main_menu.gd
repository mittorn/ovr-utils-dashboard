extends Control

const OVERLAY_PROPERTIES = {
	"allow_hide": false,
	"allow_delete": false,
	"has_cursor": true,
	"has_grab": true,
	"width":1024,
	"height":1024
}
onready var main_control = $Control
onready var overlays_control = $Control/PanelContainer/Overlays
onready var apps_control = $Control/MainVBox/PanelContainer/RunningApps

func _ready() -> void:
	OverlayManager.connect("added_overlay", self, "_add_overlay_to_list")
	OverlayManager.connect("removed_overlay", self, "_remove_overlay_from_list")
	for o in Settings.s.overlays:
		if o != "MainOverlay":
			_add_overlay_to_list(o)
	$Control/PanelContainer.visible = false
	fill_script_list()
	update_running_apps(true)
	OverlayManager.get_node("MainOverlay").connect('overlay_visible_changed2',self, 'update_running_apps')

func fill_script_list():
	$Control/MainVBox/ScriptRunner.visible = false
	var dir = Directory.new()
	dir.open(OverlayManager.exec_dir + '/vr-scripts')
	dir.list_dir_begin()
	while true:
		var f = dir.get_next()
		if f == "":
			break
		if f == '.' or f == '..':
			continue
		$Control/MainVBox/ScriptRunner.visible = true
		var b = Button.new()
		b.name = f
		b.text = f
		b.connect("button_up", self, "_run_script",[OverlayManager.exec_dir + '/vr-scripts/'+f])
		$Control/MainVBox/ScriptRunner/VBoxContainer.add_child(b)
	dir.list_dir_end()
var update_pending = false
var update_timer
func start_update_timer():
	update_timer = Timer.new()
	update_timer.one_shot = true
	update_timer.connect('timeout', self, 'update_running_apps',[false]);
	add_child(update_timer)
	update_timer.start(1)
	
func _run_script(name):
	OS.execute(name,[], false)
	update_running_apps(false)
	start_update_timer()


const keys_blacklist = ['system.generated.ovr-utils.x86_64', 'system.generated.advancedsettings', 'system.generated.godot.x11.tools.64']
var current_apps = []

func update_running_apps(_hide):
	if update_timer:
		update_timer.queue_free()
		update_timer = null
	if update_pending:
		return
	var http = HTTPRequest.new()
	add_child(http)
	http.connect("request_completed", self, "_http_request_completed")
	http.request("http://127.0.0.1:27062/app/list.json",["Referer: http://localhost:27062/dashboard/controllerbinding.html"])
	update_pending = true

func _http_request_completed(_result, _response_code, _headers, body):
	update_pending = false
	$Control/MainVBox/PanelContainer.visible = false
	var response = parse_json(body.get_string_from_utf8())
	current_apps = []
	for child in apps_control.get_children():
		if(child != $Control/MainVBox/PanelContainer/RunningApps/Label):
			child.queue_free()
	
	for app in response.apps:
		if app.pid and !app.is_internal and !(app.key in keys_blacklist):
			current_apps.append(app)
			print(app.key, ':',app.name)
			$Control/MainVBox/PanelContainer.visible = true
			var new = preload("res://ui/ListRunningAppItem.tscn").instance()
			new.app_name = app.name
			new.app_key = app.key
			new.app_pid = app.pid
			apps_control.add_child(new)
	
func _add_overlay_to_list(name):
	var new = preload("res://ui/ListOverlayItem.tscn").instance()
	new.overlay_name = name
	overlays_control.add_child(new)


func _remove_overlay_from_list(name):
	overlays_control.get_node(name).queue_free()


func _on_GrabMode_toggled(state: bool) -> void:
	Settings.s.grab_mode = state
	OverlayManager.emit_signal("grab_mode_changed")

func _on_Pause_toggled(state: bool) -> void:
	#get_tree().paused = state
	#OverlayManager.set_hide_all(true)
	OverlayManager.run_dashboard(state)
	#OverlayInteractionRoot.center_world()

func _on_ShowOverlays_toggled(state: bool) -> void:
	overlays_control.visible = state
	$Control/PanelContainer.visible = state


func _on_AddOverlay_toggled(state: bool) -> void:
	$Control/AddMenu.visible = state


func _on_QuitToggle_toggled(state: bool) -> void:
	$MainBar/QuitToggle/Quit.visible = state


func _on_Quit_pressed() -> void:
	Settings.force_save()
	get_tree().quit()


func _on_add_menu_closed() -> void:
	$MainBar/AddOverlay.pressed = false


func _on_Recenter_pressed():
	OverlayInteractionRoot.center_world()
