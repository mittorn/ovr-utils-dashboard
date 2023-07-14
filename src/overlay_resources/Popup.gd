extends "res://overlay_resources/compwindow.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func find_window():
	var window = 0
	if ScreenGrab.popup_target:
		window = compwindow.register_popup(ScreenGrab.popup_target, instance.compwindow_index)
		raise_flags = 3
		print('popup', window)
	if instance.compwindow_index == 0:
		ScreenGrab.popups_visible = (window != 0)
		ScreenGrab.popups_active = (window != 0)
	if get_parent():
		get_parent().get_parent().get_parent().overlay_visible = (window != 0)
	return window

func update_watchers():
	ScreenGrab.emit_signal('update_popups')

# Called when the node enters the scene tree for the first time.
func _ready():
	ScreenGrab.connect("update_popups", self, "update_window")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
