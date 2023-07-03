extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var OVERLAY_PROPERTIES = {
	"has_cursor": true,
	"width": ScreenGrab.screengrab.get_width(),
	"height": ScreenGrab.screengrab.get_height(),
}
var t = 0

func _draw() -> void:
	var tex = ScreenGrab.create_texture()

	var s: TextureRect = $Image
	s.margin_right = ScreenGrab.screengrab.get_width();
	s.margin_bottom = ScreenGrab.screengrab.get_height();
	tex.flags = 0
	$Image.texture = tex


func _on_Image_gui_input(event):
	return ScreenGrab.input_func(event)
