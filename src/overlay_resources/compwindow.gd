extends Control


const CompWindow = preload("res://addons/godot-screengrab/compwindow.gdns")

var compwindow = CompWindow.new()
const classnames = [
	['term', 'WM_CLASS', 'konsole', 3],
	['brsw', 'WM_CLASS', 'Navigator', 1],
	['ovras', 'WM_CLASS', 'AdvancedSettings', 0],
	['godot', 'WM_CLASS', 'Godot_Editor', 1]
]
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
var raise_flags = 3
var desktop_layer = false
func update_texture():
	desktop_layer = false
	if not tex:
		tex = ExternalTexture.new()
		id = tex.get_external_texture_id()
		#screengrab.update_texture(id)

	compwindow.update_texture(id)
	if !compwindow.get_id():
		return
	var s: TextureRect = $Image
	#s.margin_top = 40
	#s.margin_left = 0
	#s.margin_right = compwindow.get_width();
	#s.margin_bottom = compwindow.get_height()+40;
	s.rect_size = Vector2(compwindow.get_width(), compwindow.get_height())
	s.rect_position = Vector2(0,40)
	tex.flags = 0
	s.texture = tex

func _draw() -> void:
	if compwindow.get_id() && !tex:
		update_texture()
	
func update_window(first = false):
	if instance.compwindow_class < 0:
		instance.compwindow_class = 0;
	if instance.compwindow_class >= len(classnames):
		instance.compwindow_class = len(classnames) - 1
	$Buttons/Index.text = str(instance.compwindow_index)
	$Buttons/Classname.text = classnames[instance.compwindow_class][0]
	var window = compwindow.register_window(classnames[instance.compwindow_class][1],classnames[instance.compwindow_class][2],instance.compwindow_index)
	raise_flags = classnames[instance.compwindow_class][3]
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


func _on_Activate_pressed():
	compwindow.window_activate(raise_flags, 100,100)


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


# Declare member variables here. Examples:
# var a = 2
# var b = "text"



var press_x = -999
var press_y = -999
var last_x = -999
var last_y = -999
var last_pressed = 0
var keystate: int = 0
const keymods = {
	'SHIFT':0x1,
	'CAPSLOCK': 0x2,
	'CONTROL': 0x4,
	'ALT': 0x8,
	'SUPER': 0x40
}
# send caps with xtest
var repeat_key = ''
func set_key_state(key, pressed):
	if desktop_layer:
		return ScreenGrab.set_key_state(key, pressed)
	if key in keymods:
		if pressed:
			keystate |= keymods[key]
		else:
			keystate &= ~keymods[key] & 0xFF
		if(key == 'CAPSLOCK'):
			ScreenGrab.screengrab.set_key_state(key, pressed)
	else:
		if !pressed:
			repeat_key = ''
		else:
			if len(key) == 1 || key == 'BACKSPACE':
				repeat_key = key
				repeat_next = repeat_time + 0.4
			
	compwindow.set_key_state(key, pressed, keystate)
var repeat_time = 0
var repeat_next = 0
func _process(delta):
	repeat_time += delta
	if repeat_next < repeat_time && len(repeat_key):
		repeat_next = repeat_time + 0.05
		compwindow.set_key_state(repeat_key, 1, keystate)

func set_mouse(button, clicked):
	if desktop_layer:
		return ScreenGrab.set_mouse(button, clicked)
	var b = 0x100 << (button - 1)
	if !clicked:
		b = 0
	compwindow.window_update_mouse(b | keystate, raise_flags, last_x, last_y)
	repeat_key = ''

func send_scroll(up, count):
	if desktop_layer:
		return ScreenGrab.send_scroll(up, count)
	var i = 0
	var b
	if up:
		b = 4
	else:
		b = 5
	while i < count:
		set_mouse(b, true)
		set_mouse(b, false)
		i = i+1



func _on_Image_gui_input(event):
	if !compwindow.get_id():
		return
	if desktop_layer:
		if event.position.y > 0:
			ScreenGrab.input_func(event)
			OverlayManager.keyboard_target = self
		return
	if event is InputEventMouseMotion && (!last_pressed||abs(event.position.x - press_x)+abs(event.position.y - press_y) > 55):
		if abs(last_x - event.position.x) + abs(last_y - event.position.y) > 4 || last_pressed:
			if OverlayManager.desktop_active:
				compwindow.window_activate(raise_flags, event.position.x, event.position.y )
				OverlayManager.desktop_active = false
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
			if event.position.y > 0:
				compwindow.window_update_mouse(0xFF00 | keystate, raise_flags, event.position.x, event.position.y)
			last_x = event.position.x
			last_y = event.position.y
	if event is InputEventMouseButton:
		repeat_key = ''
		OverlayManager.keyboard_target = self
		#print(event.position.x)
		#if abs(event.position.x - press_x)+abs(event.position.y - press_y) > 100:
		
			#OS.execute('xdotool',['mousemove', '%d' % (event.position.x), '%d' % (event.position.y)])
		#print(event.pressed)
		var state
		if event.pressed:
			state = 0x100
		else:
			state = 0
		if event.position.y > 0:
			compwindow.window_update_mouse( state | keystate, raise_flags, event.position.x, event.position.y )
		if !last_pressed && event.pressed:
			press_x = event.position.x
			press_y = event.position.y
		last_pressed = event.pressed
		#print('xdotool', state, 1)
		#OS.execute('xdotool',[state, '1'])

