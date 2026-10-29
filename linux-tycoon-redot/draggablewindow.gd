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
	clip_contents = false

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
		var tl_w := float(_tex_tl.get_width())
		var tl_h := float(_tex_tl.get_height())
		var tr_w := float(_tex_tr.get_width())
		var tr_h := float(_tex_tr.get_height())
		var bl_w := float(_tex_bl.get_width())
		var bl_h := float(_tex_bl.get_height())
		var br_w := float(_tex_br.get_width())
		var br_h := float(_tex_br.get_height())

		var top_h := float(_tex_top.get_height())
		var bot_h := float(_tex_bottom.get_height())
		var left_w := float(_tex_left.get_width())
		var right_w := float(_tex_right.get_width())

		# 1. Draw interior background (inset from borders so corners don't bleed)
		draw_texture_rect(
			_tex_bg,
			Rect2(left_w, top_h, w - left_w - right_w, h - top_h - bot_h),
			true
		)

		# 2. Draw Top & Bottom edges strictly between the left and right corner pieces
		draw_texture_rect(
			_tex_top,
			Rect2(tl_w, 0, w - tl_w - tr_w, top_h),
			true
		)
		draw_texture_rect(
			_tex_bottom,
			Rect2(bl_w, h - bot_h, w - bl_w - br_w, bot_h),
			true
		)

		# 3. Draw Left & Right edges strictly between the top and bottom corner pieces
		draw_texture_rect(
			_tex_left,
			Rect2(0, tl_h, left_w, h - tl_h - bl_h),
			true
		)
		draw_texture_rect(
			_tex_right,
			Rect2(w - right_w, tr_h, right_w, h - tr_h - br_h),
			true
		)

		# 4. Stamp the 4 rounded corners cleanly
		draw_texture(_tex_tl, Vector2.ZERO)
		draw_texture(_tex_tr, Vector2(w - tr_w, 0))
		draw_texture(_tex_bl, Vector2(0, h - bl_h))
		draw_texture(_tex_br, Vector2(w - br_w, h - br_h))
	else:
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