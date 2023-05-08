extends Control


const ScreenGrab = preload("res://addons/godot-screengrab/screengrab.gdns")

var screengrab = ScreenGrab.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
var OVERLAY_PROPERTIES = {
	"has_cursor": true,
	"width": screengrab.get_width(),
	"height": screengrab.get_height(),
}
var t = 0
var tex
var id

func _draw() -> void:
	if not tex:
		tex = ExternalTexture.new()
		id = tex.get_external_texture_id()
		screengrab.update_texture(id)

	var s: TextureRect = $Image
	s.margin_right = screengrab.get_width();
	s.margin_bottom = screengrab.get_height();
	tex.flags = 0
	$Image.texture = tex
