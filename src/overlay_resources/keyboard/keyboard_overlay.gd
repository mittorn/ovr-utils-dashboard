extends Control

const OVERLAY_PROPERTIES = {
#	"has_touch": true,
	"has_cursor" : true,
		"width": 1900*0.5,
	"height": 700*0.5,
	"skip_keyboard": true
}

export var key_size := 50
export var key_row : PackedScene
export var key_button : PackedScene
export var row_container_path : NodePath

var row_container
var keymap := {}
var toggle_keys := []

func _ready():
	row_container = get_node(row_container_path)
	load_keys("res://overlay_resources/keyboard/layouts/layout_usru.json")
	OverlayManager.connect("toggle_kb", self, "_toggle_kb")

func _toggle_kb():
	print("toggle_kb")
	var p = get_parent().get_parent().get_parent()
	p.overlay_visible = !p.overlay_visible #!get_parent().overlay_visible                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            

func load_keys(fp: String):
	var file = File.new()
	file.open(fp, File.READ)
	keymap = parse_json(file.get_as_text())
	file.close()
	
	apply_keys()


func apply_keys():
	for row in keymap.rows:
		var row_box = key_row.instance()
		row_container.add_child(row_box)
		for key in row.keys:
			var btn = key_button.instance()
			btn.set_focus_mode(0)
			
			if not key.has("display"):
				key.display = key.keycode
			btn.get_node("Label").text = key.display
			btn.name = key.keycode
			
			btn.rect_min_size.x = key_size
			btn.rect_min_size.y = key_size
			if key.has("width"):
				btn.rect_min_size.x *= key.width
			
			if key.has("toggle") and key.toggle:
				btn.toggle_mode = true
				btn.connect("toggled", self, "key_toggled", [key.keycode])
				toggle_keys.append(btn)
			else:
				btn.connect("button_down", self, "key_down", [key.keycode])
				btn.connect("button_up", self, "key_up", [key.keycode])
				
			row_box.add_child(btn)
			
			# horizontal gaps
			if key.has("gap"):
				var gapbox = Control.new()
				gapbox.set_focus_mode(0)
				gapbox.rect_min_size.x = key.gap * key_size
				gapbox.name = "Gap"
				row_box.add_child(gapbox)

		# vertical gaps
		if row.has("gap") and row.gap > 0:
			var gapbox = Control.new()
			gapbox.set_focus_mode(0)
			gapbox.rect_min_size.y = row.gap * key_size
			gapbox.name = "Gap"
			row_container.add_child(gapbox)


func key_toggled(state, code):
	if state:
		#GDVK.key_down(code)
		ScreenGrab.keyboard_target.set_key_state(code, true)
	else:
		#GDVK.key_up(code)
		ScreenGrab.keyboard_target.set_key_state(code, false)


func key_down(code):
	#GDVK.key_down(code)
	ScreenGrab.keyboard_target.set_key_state(code, true)


func key_up(code):
	#GDVK.key_up(code)
	ScreenGrab.keyboard_target.set_key_state(code, false)
	# clear all modifier keys
	for k in toggle_keys:
		if k.pressed:
			k.pressed = false
	
