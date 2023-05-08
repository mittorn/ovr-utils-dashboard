extends Control

export var app_name: String
export var app_key: String
export var app_pid: int

func _ready() -> void:


	$BasicOptions/Label.text = app_name
	$BasicOptions/Label2.text = app_key
	name = app_key


func _apply_loaded():
	_update_warning()


func _update_warning():
	#$BasicOptions/List/Warning.visible = overlay.path_invalid
	#$BasicOptions/List/Warning/WarningInfo/Label.text = overlay.path + "\nnot found"
	pass


func _on_Kill_pressed():
	OS.execute("kill", ['-TERM', str(app_pid)])
	get_node('/root/OverlayManager/MainOverlay/OverlayViewport/Container/MainOverlay').start_update_timer()
