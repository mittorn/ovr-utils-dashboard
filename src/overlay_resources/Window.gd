extends "res://overlay_resources/compwindow.gd"


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var watch_modals


func update_watchers():
	print('find modals')

func find_window():
	if instance.compwindow_class < 0:
		instance.compwindow_class = 0;
	if instance.compwindow_class >= len(classnames):
		instance.compwindow_class = len(classnames) - 1
	var window = compwindow.register_window(classnames[instance.compwindow_class][1],classnames[instance.compwindow_class][2],instance.compwindow_index)
	raise_flags = classnames[instance.compwindow_class][3]
	print(window)
	$Buttons/Title.text = compwindow.get_window_title()
	$Buttons/Classname.text = classnames[instance.compwindow_class][0]
	return window


func _on_DesktopToggle_toggled(button_pressed):
	desktop_layer = button_pressed
	if desktop_layer:
		compwindow.window_activate(0xF, 100,100)
		var s: TextureRect = $Image
		s.texture = ScreenGrab.create_texture()
		s.rect_size = Vector2(ScreenGrab.screengrab.get_width(),ScreenGrab.screengrab.get_height())
		s.rect_position = Vector2(-compwindow.get_x(), -compwindow.get_y()+40)
	else:
		update_texture()

func _on_PrevClass_pressed():
	instance.compwindow_class -= 1
	update_window()


func _on_NextClass_pressed():
	instance.compwindow_class += 1
	update_window()


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_ModalToggle_toggled(button_pressed):
	watch_modals = button_pressed
