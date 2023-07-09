extends "res://overlay_resources/compwindow.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func update_watchers():
	ScreenGrab.emit_signal('update_modals')
	ScreenGrab.trigger_modals = true

func find_window():
	var window = compwindow.register_window('WM_TRANSIENT_FOR',str(ScreenGrab.modal_target), instance.compwindow_index)
	raise_flags = ScreenGrab.modal_flags
	print('modal',window)
	if get_parent():
		get_parent().get_parent().get_parent().overlay_visible = (window != 0)
	return window

# Called when the node enters the scene tree for the first time.
func _ready():
	ScreenGrab.connect("update_modals", self, "update_window")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
