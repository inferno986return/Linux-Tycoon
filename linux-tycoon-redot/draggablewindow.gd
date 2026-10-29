class_name DraggableWindow
extends Panel

var _dragging: bool = false
var _drag_offset: Vector2 = Vector2.ZERO

static var _tex_bg: Texture2D
static var _tex_top: Texture2D
static var _tex_bottom: Texture2D
static var _tex_left: Texture2D
static var _tex_right: Texture2D
static var _tex_tl: Texture2D
static var _tex_tr: Texture2D
static var _tex_bl: Texture2D
static var _tex_br: Texture2D
static var _textures_checked: bool = false

func _init() -> void:
	var empty := StyleBoxEmpty.new()
	add_theme_stylebox_override("panel", empty)
	clip_contents = true

static func _load_border_textures() -> void:
	if _textures_checked:
		return
	_textures_checked = true
	if ResourceLoader.exists("res://WinBorder/Background.png"):
		_tex_bg = load("res://WinBorder/Background.png")
		_tex_top = load("res://WinBorder/TopRepeat.png")
		_tex_bottom = load("res://WinBorder/BottomRepeat.png")
		_tex_left = load("res://WinBorder/LeftRepeat.png")
		_tex_right = load("res://WinBorder/RightRepeat.png")
		_tex_tl = load("res://WinBorder/TopLeft.png")
		_tex_tr = load("res://WinBorder/TopRight.png")
		_tex_bl = load("res://WinBorder/BottomLeft.png")
		_tex_br = load("res://WinBorder/BottomRight.png")

func _draw() -> void:
	_load_border_textures()
	var w := size.x
	var h := size.y
	if _tex_bg != null:
		# Exact port of ReDrawBG() from Xojo
		var bw := _tex_bg.get_width()
		var bh := _tex_bg.get_height()
		for ix in range(int(w / bw) + 1):
			for iy in range(int(h / bh) + 1):
				draw_texture(_tex_bg, Vector2(ix * bw, iy * bh))
		
		var tw := _tex_top.get_width()
		for ix in range(int(w / tw) + 1):
			draw_texture(_tex_top, Vector2(ix * tw, 0))
			
		var botw := _tex_bottom.get_width()
		var both := _tex_bottom.get_height()
		for ix in range(int(w / botw) + 1):
			draw_texture(_tex_bottom, Vector2(ix * botw, h - both))
			
		var lh := _tex_left.get_height()
		for iy in range(int(h / lh) + 1):
			draw_texture(_tex_left, Vector2(0, iy * lh))
			
		var rw := _tex_right.get_width()
		var rh := _tex_right.get_height()
		for iy in range(int(h / rh) + 1):
			draw_texture(_tex_right, Vector2(w - rw, iy * rh))
			
		draw_texture(_tex_tl, Vector2.ZERO)
		draw_texture(_tex_tr, Vector2(w - _tex_tr.get_width(), 0))
		draw_texture(_tex_bl, Vector2(0, h - _tex_bl.get_height()))
		draw_texture(_tex_br, Vector2(w - _tex_br.get_width(), h - _tex_br.get_height()))
	else:
		# Fallback if WinBorder folder isn't copied yet
		draw_rect(Rect2(0, 0, w, h), Color8(137, 167, 209))
		draw_rect(Rect2(0, 0, w, h), Color8(60, 107, 173), false, 2.0)

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_dragging = true
			_drag_offset = event.position
			move_to_front()
		else:
			_dragging = false
	elif event is InputEventMouseMotion and _dragging:
		position += event.position - _drag_offset