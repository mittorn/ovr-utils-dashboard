extends Control


const CompWindow = preload("res://addons/godot-screengrab/compwindow.gdns")

var compwindow = CompWindow.new()
var classnames = ['Navigator', 'konsole', 'AdvancedSettings']
# Called when the node enters the scene tree for the first time.
func _ready():

	pass # Replace with function body.

var OVERLAY_PROPERTIES = {
	"has_cursor": true,
	"width": 1920,
	"height": 1120
}
var instance
func pre_prop_callback(_instance):
	instance = _instance
	update_window(true)

var t = 0
var tex
var id

func update_texture():

	if not tex:
		tex = ExternalTexture.new()
		id = tex.get_external_texture_id()
		#screengrab.update_texture(id)

	compwindow.update_texture(id)
	if !compwindow.get_id():
		return
	var s: TextureRect = $Image
	s.margin_right = compwindow.get_width();
	s.margin_bottom = compwindow.get_height()+40;
	tex.flags = 0
	$Image.texture = tex

func _draw() -> void:
	if compwindow.get_id() && !tex:
		update_texture()
	
func update_window(first = false):
	if instance.compwindow_class < 0 || instance.compwindow_class > 2:
		instance.compwindow_class = 0;
	$Buttons/Index.text = str(instance.compwindow_index)
	$Buttons/Classname.text = classnames[instance.compwindow_class]
	var window = compwindow.register_window(classnames[instance.compwindow_class],instance.compwindow_index)
	print(window)
	$Buttons/Title.text = compwindow.get_window_title()
	if window:
		OVERLAY_PROPERTIES.width  = max(compwindow.get_width(), 320)
		OVERLAY_PROPERTIES.height = max(compwindow.get_height()+40, 40)
		if !first:
			instance.OVERLAY_PROPERTIES.width = OVERLAY_PROPERTIES.width
			instance.OVERLAY_PROPERTIES.height = OVERLAY_PROPERTIES.height
			instance.try_update_size()
	if !first:
		update_texture()
	pass

func _on_ButtonPrev_pressed():
	instance.compwindow_index -= 1
	update_window()


func _on_ButtonNext_pressed():
	instance.compwindow_index += 1
	update_window()


func _on_PrevClass_pressed():
	instance.compwindow_class -= 1
	update_window()


func _on_NextClass_pressed():
	instance.compwindow_class += 1
	update_window()
