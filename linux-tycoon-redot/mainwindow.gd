extends Control

var day_timer: Timer
var lbl_date: Label
var btn_pause: Button
var can_main: Control

# Sub-containers
var con_main_menu: DraggableWindow
var con_intro: DraggableWindow
var con_distro_stats: DraggableWindow
var con_distro_rank: DraggableWindow
var con_overview: DraggableWindow
var con_notifications: DraggableWindow
var con_package_selection: DraggableWindow
var con_worker_assignment: DraggableWindow
var con_sacrifice_worker: DraggableWindow
var con_new_release: DraggableWindow

# UI Element References for dynamic updates
var lbl_scenario: Label
var intro_step: int = 0
var intro_lbl: Label
var intro_txt_name: LineEdit
var intro_btn_next: Button

var stats_logo: TextureRect
var stats_lbl_name: Label
var stats_lbl_ver: Label
var stats_lbl_hype: Label
var stats_lbl_bugs: Label
var stats_lbl_size: Label
var stats_lbl_vol: Label
var stats_lbl_paid: Label
var stats_btn_packages: Button
var stats_btn_workers: Button
var stats_btn_release: Button
var stats_btn_save: Button

var overview_lbl_name: Label
var overview_lbl_users: Label
var overview_lbl_age: Label

var rank_vbox: VBoxContainer
var notif_lbl: RichTextLabel
var pkg_vbox: VBoxContainer

var work_list_vbox: VBoxContainer
var work_selected_idx: int = 0
var work_lbl_avail_paid: Label
var work_lbl_avail_vol: Label
var work_lbl_pkg_name: Label
var work_lbl_assign_paid: Label
var work_lbl_assign_vol: Label

var sac_lbl_avail: Label
var sac_lbl_results: Label
var release_lbl_text: Label

var confirm_release_dlg: ConfirmationDialog
var file_dlg_save: FileDialog
var file_dlg_load: FileDialog
var file_dlg_scenario: FileDialog

var tex_tux: Texture2D
var tex_bryan: Texture2D

func _ready() -> void:
	if ResourceLoader.exists("res://Tux32x32.png"):
		tex_tux = load("res://Tux32x32.png")
	if ResourceLoader.exists("res://Bryan.png"):
		tex_bryan = load("res://Bryan.png")

	_apply_xojo_theme()
	_build_base_layout()
	_build_con_main_menu()
	_build_con_intro()
	_build_con_distro_stats()
	_build_con_overview()
	_build_con_distro_rank()
	_build_con_notifications()
	_build_con_package_selection()
	_build_con_worker_assignment()
	_build_con_sacrifice_worker()
	_build_con_new_release()
	_build_dialogs()

	GameManager.stats_updated.connect(_on_stats_updated)
	GameManager.message_added.connect(_on_message_added)
	GameManager.scenario_loaded.connect(func(s_name: String): lbl_scenario.text = "Scenario: " + s_name)

	resized.connect(_setup_initial_positions)
	_setup_initial_positions()
	_hide_all_containers()
	con_main_menu.visible = true

func _apply_xojo_theme() -> void:
	var t := Theme.new()
	t.default_font_size = 13 

	var sb_normal := _make_btn_style(Color8(89, 131, 192), Color8(60, 107, 173))
	var sb_hover := _make_btn_style(Color8(47, 92, 159), Color8(60, 107, 173))
	var sb_pressed := _make_btn_style(Color8(35, 75, 140), Color8(60, 107, 173))
	var sb_disabled := _make_btn_style(Color8(59, 101, 162), Color8(60, 107, 173))

	t.set_stylebox("normal", "Button", sb_normal)
	t.set_stylebox("hover", "Button", sb_hover)
	t.set_stylebox("pressed", "Button", sb_pressed)
	t.set_stylebox("disabled", "Button", sb_disabled)
	t.set_stylebox("focus", "Button", sb_normal)

	t.set_color("font_color", "Button", Color.WHITE)
	t.set_color("font_hover_color", "Button", Color.WHITE)
	t.set_color("font_pressed_color", "Button", Color.WHITE)
	t.set_color("font_disabled_color", "Button", Color8(200, 200, 200))

	var sb_empty := StyleBoxEmpty.new()
	t.set_stylebox("normal", "CheckBox", sb_empty)
	t.set_stylebox("hover", "CheckBox", sb_empty)
	t.set_stylebox("pressed", "CheckBox", sb_empty)
	t.set_stylebox("hover_pressed", "CheckBox", sb_empty)
	t.set_stylebox("focus", "CheckBox", sb_empty)

	var sb_edit := _make_btn_style(Color.WHITE, Color8(60, 107, 173))
	t.set_stylebox("normal", "LineEdit", sb_edit)
	t.set_stylebox("focus", "LineEdit", sb_edit)
	t.set_color("font_color", "LineEdit", Color.BLACK)
	t.set_color("caret_color", "LineEdit", Color.BLACK)
	
	# Popup Window Styling
	var sb_window := StyleBoxFlat.new()
	sb_window.bg_color = Color8(180, 198, 228) 
	sb_window.border_color = Color8(60, 107, 173) 
	sb_window.set_border_width_all(4)
	t.set_stylebox("panel", "Window", sb_window)
	
	var sb_inner := StyleBoxFlat.new()
	sb_inner.bg_color = Color8(89, 131, 192) 
	sb_inner.border_color = Color8(60, 107, 173)
	sb_inner.set_border_width_all(1)
	t.set_stylebox("panel", "Tree", sb_inner)
	t.set_stylebox("panel", "ItemList", sb_inner)
	
	t.set_color("font_color", "Tree", Color.WHITE)
	t.set_color("font_color", "ItemList", Color.WHITE)
	t.set_color("title_color", "Window", Color.BLACK)

	theme = t

func _make_btn_style(bg: Color, border: Color) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = bg
	sb.border_color = border
	sb.set_border_width_all(1)
	sb.content_margin_left = 16
	sb.content_margin_right = 16
	sb.content_margin_top = 8
	sb.content_margin_bottom = 8
	return sb

func _build_base_layout() -> void:
	var bg := ColorRect.new()
	bg.color = Color8(180, 198, 228)
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	if ResourceLoader.exists("res://WinBorder/Background.png"):
		var bg_tex := TextureRect.new()
		bg_tex.texture = load("res://WinBorder/Background.png")
		bg_tex.stretch_mode = TextureRect.STRETCH_TILE
		bg_tex.set_anchors_preset(Control.PRESET_FULL_RECT)
		bg_tex.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		add_child(bg_tex)

	var top_bar := Control.new()
	top_bar.set_anchors_preset(Control.PRESET_TOP_WIDE)
	top_bar.offset_bottom = 22
	add_child(top_bar)

	lbl_date = Label.new()
	lbl_date.anchor_left = 1.0
	lbl_date.anchor_right = 1.0
	lbl_date.offset_left = -262
	lbl_date.offset_right = -30
	lbl_date.offset_top = 1
	lbl_date.offset_bottom = 21
	lbl_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_date.add_theme_color_override("font_color", Color.BLACK)
	top_bar.add_child(lbl_date)

	btn_pause = Button.new()
	btn_pause.anchor_left = 1.0
	btn_pause.anchor_right = 1.0
	btn_pause.offset_left = -22
	btn_pause.offset_right = 0
	btn_pause.offset_top = 0
	btn_pause.offset_bottom = 22
	btn_pause.text = "||"
	btn_pause.visible = false
	btn_pause.pressed.connect(_on_btn_pause_pressed)
	top_bar.add_child(btn_pause)

	can_main = Control.new()
	can_main.set_anchors_preset(Control.PRESET_FULL_RECT)
	can_main.offset_top = 22
	add_child(can_main)

	day_timer = Timer.new()
	day_timer.wait_time = 1.0
	day_timer.timeout.connect(_on_day_timer_timeout)
	add_child(day_timer)

func _build_con_main_menu() -> void:
	con_main_menu = DraggableWindow.new()
	con_main_menu.size = Vector2(620, 430) 
	can_main.add_child(con_main_menu)

	var icon := TextureRect.new()
	icon.texture = tex_tux
	icon.position = Vector2(30, 30)
	icon.size = Vector2(32, 32)
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_main_menu.add_child(icon)

	_add_label(con_main_menu, "Linux Tycoon Classic (Redot)", Vector2(75, 30), Vector2(340, 32), 22)
	_add_label(con_main_menu, "1.1.2", Vector2(75, 75), Vector2(340, 22), 13)
	lbl_scenario = _add_label(con_main_menu, "Scenario: Standard", Vector2(75, 110), Vector2(340, 22), 13)
	
	var link_lunduke := LinkButton.new()
	link_lunduke.text = "www.Lunduke.com"
	link_lunduke.position = Vector2(75, 145)
	link_lunduke.add_theme_font_size_override("font_size", 13)
	link_lunduke.add_theme_color_override("font_color", Color.WHITE)
	link_lunduke.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_lunduke.uri = "https://www.lunduke.com/"
	con_main_menu.add_child(link_lunduke)

	var support_lbl := _add_label(con_main_menu, "Support Bryan Lunduke by purchasing the Linux Tycoon Mega Collection for $12 on itch.io:", Vector2(75, 185), Vector2(330, 45), 11)
	support_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	support_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	var link_itch := LinkButton.new()
	link_itch.text = "https://lunduke.itch.io/linux-tycoon-mega-collection/"
	link_itch.position = Vector2(75, 225)
	link_itch.add_theme_font_size_override("font_size", 11)
	link_itch.add_theme_color_override("font_color", Color.WHITE)
	link_itch.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_itch.uri = "https://lunduke.itch.io/linux-tycoon-mega-collection/"
	con_main_menu.add_child(link_itch)

	var vbox := VBoxContainer.new()
	vbox.position = Vector2(430, 30)
	vbox.size = Vector2(160, 370)
	vbox.add_theme_constant_override("separation", 12) 
	con_main_menu.add_child(vbox)

	var btn_new := Button.new()
	btn_new.text = "New Game"
	btn_new.pressed.connect(func():
		GameManager.reset_new_game_state()
		con_main_menu.visible = false
		_start_intro()
	)
	vbox.add_child(btn_new)

	var btn_load := Button.new()
	btn_load.text = "Resume Game"
	btn_load.pressed.connect(func(): file_dlg_load.popup_centered())
	vbox.add_child(btn_load)

	var btn_import := Button.new()
	btn_import.text = "Import Scenario"
	btn_import.pressed.connect(func(): file_dlg_scenario.popup_centered())
	vbox.add_child(btn_import)
	
	var btn_online := Button.new()
	btn_online.text = "Online Game"
	btn_online.disabled = true
	vbox.add_child(btn_online)
	
	var btn_server := Button.new()
	btn_server.text = "Run Server"
	btn_server.disabled = true
	vbox.add_child(btn_server)
	
	var btn_settings := Button.new()
	btn_settings.text = "Settings"
	btn_settings.disabled = true
	vbox.add_child(btn_settings)

	var btn_credits := Button.new()
	btn_credits.text = "Credits"
	btn_credits.disabled = true
	vbox.add_child(btn_credits)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var btn_quit := Button.new()
	btn_quit.text = "Quit"
	btn_quit.pressed.connect(func(): get_tree().quit())
	vbox.add_child(btn_quit)

func _build_con_intro() -> void:
	con_intro = DraggableWindow.new()
	con_intro.size = Vector2(500, 360)
	can_main.add_child(con_intro)

	var bryan := TextureRect.new()
	bryan.texture = tex_bryan
	bryan.position = Vector2(25, 25)
	bryan.size = Vector2(46, 99)
	bryan.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_intro.add_child(bryan)

	intro_lbl = _add_label(con_intro, "", Vector2(90, 25), Vector2(380, 250), 13)
	intro_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	intro_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	intro_txt_name = LineEdit.new()
	intro_txt_name.position = Vector2(90, 295)
	intro_txt_name.size = Vector2(180, 34)
	intro_txt_name.text = "MyLinuxDistro"
	con_intro.add_child(intro_txt_name)

	intro_btn_next = _add_button(con_intro, "Set Distro Name", Vector2(285, 295), Vector2(185, 34))
	intro_btn_next.pressed.connect(_on_intro_next_pressed)

func _start_intro() -> void:
	intro_step = 0
	center_container(con_intro)
	con_intro.visible = true
	intro_txt_name.visible = true
	intro_txt_name.text = "MyLinuxDistro"
	intro_btn_next.text = "Set Distro Name"
	intro_lbl.text = "Want to build the greatest Linux Distribution (aka \"Distro\") in the history of mankind?\n\nGood. Because this is Linux Tycoon, not \"Cute Fuzzy Puppy Tycoon.\"\n\nMy name is Bryan. I will be your guide to the cut-throat world of Linux Distro building.\n\nTo get started, you should probably name your Linux Distro. Think hard. You'll be stuck with this name for a long, long time."

func _on_intro_next_pressed() -> void:
	if intro_step == 0:
		var chosen := intro_txt_name.text.strip_edges()
		GameManager.my_distro.name = chosen if not chosen.is_empty() else "MyLinuxDistro"
		intro_step = 1
		intro_txt_name.visible = false
		intro_btn_next.text = "Edit Packages"
		intro_lbl.text = "Now that you've got a name, it's time to figure out which packages you'll want to include in your Linux Distro.\n\nA \"package\" is an app (or a collection of apps) that will be available in your Distro. This can include everything from your basic desktop environment to your web browser (and beyond).\n\nSo pick carefully. Click \"Edit Packages\" to get started. (Okay, you don't have to be *that* careful, you can change your packages later.)"
	elif intro_step == 1:
		con_intro.visible = false
		center_container(con_package_selection)
		_refresh_package_selection()
		con_package_selection.visible = true
	elif intro_step == 2:
		stats_btn_packages.disabled = false
		stats_btn_release.disabled = false
		con_intro.visible = false
		GameManager.is_first_run = false
		_refresh_distro_stats()

func _build_con_distro_stats() -> void:
	con_distro_stats = DraggableWindow.new()
	con_distro_stats.size = Vector2(165, 410)
	can_main.add_child(con_distro_stats)

	stats_logo = TextureRect.new()
	stats_logo.texture = tex_tux
	stats_logo.position = Vector2(65, 13)
	stats_logo.size = Vector2(32, 32)
	stats_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_distro_stats.add_child(stats_logo)

	var lbl_dev := _add_label(con_distro_stats, "In Development", Vector2(18, 44), Vector2(127, 20), 10, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_dev.add_theme_color_override("font_color", Color8(229, 229, 229))

	stats_lbl_name = _add_label(con_distro_stats, "", Vector2(18, 63), Vector2(127, 20), 12, HORIZONTAL_ALIGNMENT_CENTER)
	stats_lbl_ver = _add_label(con_distro_stats, "Version 1.0", Vector2(18, 82), Vector2(127, 20), 11, HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(con_distro_stats, "Hype :", Vector2(18, 106), Vector2(100, 20), 11)
	stats_lbl_hype = _add_label(con_distro_stats, "0", Vector2(67, 106), Vector2(78, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Bugs :", Vector2(18, 131), Vector2(100, 20), 11)
	stats_lbl_bugs = _add_label(con_distro_stats, "0", Vector2(67, 131), Vector2(78, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Size (MB) :", Vector2(18, 156), Vector2(100, 20), 11)
	stats_lbl_size = _add_label(con_distro_stats, "0", Vector2(102, 156), Vector2(43, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Volunteers :", Vector2(18, 182), Vector2(100, 20), 11)
	stats_lbl_vol = _add_label(con_distro_stats, "0 / 0", Vector2(92, 182), Vector2(53, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Paid Workers :", Vector2(18, 207), Vector2(100, 20), 11)
	stats_lbl_paid = _add_label(con_distro_stats, "0 / 0", Vector2(102, 207), Vector2(43, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	stats_btn_packages = _add_button(con_distro_stats, "Edit Packages", Vector2(18, 238), Vector2(127, 22))
	stats_btn_packages.pressed.connect(func():
		pause_game()
		_hide_all_containers()
		center_container(con_package_selection)
		_refresh_package_selection()
		con_package_selection.visible = true
	)

	stats_btn_workers = _add_button(con_distro_stats, "Assign Workers", Vector2(18, 276), Vector2(127, 22))
	stats_btn_workers.pressed.connect(func():
		pause_game()
		_hide_all_containers()
		work_selected_idx = 0
		center_container(con_worker_assignment)
		_refresh_worker_assignment()
		con_worker_assignment.visible = true
	)

	stats_btn_release = _add_button(con_distro_stats, "Release Version", Vector2(18, 314), Vector2(127, 22))
	stats_btn_release.pressed.connect(func(): 
		pause_game()
		confirm_release_dlg.popup_centered()
	)

	stats_btn_save = _add_button(con_distro_stats, "Save", Vector2(18, 352), Vector2(127, 22))
	stats_btn_save.disabled = true
	stats_btn_save.pressed.connect(func(): 
		pause_game()
		file_dlg_save.popup_centered()
	)

func _refresh_distro_stats() -> void:
	var d := GameManager.my_distro
	if d == null:
		return
	stats_lbl_name.text = d.name
	stats_lbl_bugs.text = str(d.get_distro_bugs())
	stats_lbl_hype.text = str(d.hype)
	stats_lbl_ver.text = "Version %d.0" % d.version
	stats_lbl_paid.text = "%d / %d" % [d.get_distro_worker_available_paid(), d.workers_paid]
	stats_lbl_vol.text = "%d / %d" % [d.get_distro_worker_available_volunteer(), d.workers_volunteers]
	stats_lbl_size.text = str(d.get_distro_size_in_mb())

	var has_workers := (d.workers_paid > 0 or d.workers_volunteers > 0) and d.packages_included.size() > 0
	stats_btn_workers.disabled = not has_workers or GameManager.is_first_run
	stats_btn_save.disabled = d.released_ver <= 0

func _build_con_overview() -> void:
	con_overview = DraggableWindow.new()
	con_overview.size = Vector2(427, 50)
	can_main.add_child(con_overview)

	overview_lbl_name = _add_label(con_overview, "", Vector2(20, 15), Vector2(145, 20), 11)
	overview_lbl_users = _add_label(con_overview, "Users: 0", Vector2(174, 15), Vector2(110, 20), 11)
	overview_lbl_age = _add_label(con_overview, "Age: 0 days", Vector2(292, 15), Vector2(120, 20), 11)

func _refresh_overview() -> void:
	var d := GameManager.my_distro
	if d == null:
		return
	overview_lbl_name.text = "%s %d.0" % [d.name, d.released_ver]
	overview_lbl_users.text = "Users: %d" % d.users
	overview_lbl_age.text = "Age: %d days" % d.get_distro_age_in_days()

func _build_con_distro_rank() -> void:
	con_distro_rank = DraggableWindow.new()
	con_distro_rank.size = Vector2(173, 314)
	can_main.add_child(con_distro_rank)

	_add_label(con_distro_rank, "DistroRank", Vector2(12, 11), Vector2(149, 20), 11, HORIZONTAL_ALIGNMENT_CENTER)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(12, 33)
	bg.size = Vector2(149, 261)
	con_distro_rank.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 33)
	scroll.size = Vector2(149, 261)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_distro_rank.add_child(scroll)

	rank_vbox = VBoxContainer.new()
	rank_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	rank_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(rank_vbox)

func _refresh_distro_rank() -> void:
	for child in rank_vbox.get_children():
		child.queue_free()

	var all_list: Array[DistroData] = []
	all_list.append(GameManager.my_distro)
	for d in GameManager.other_distros:
		all_list.append(d)

	all_list.sort_custom(func(a: DistroData, b: DistroData): return a.users > b.users)

	for i in range(all_list.size()):
		var d := all_list[i]
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(140, 28)
		row.color = Color8(230, 240, 255) if d == GameManager.my_distro else (Color.WHITE if i % 2 == 0 else Color8(245, 245, 245))

		var l_num := _add_label(row, str(i + 1), Vector2(3, 4), Vector2(24, 20), 13)
		l_num.add_theme_color_override("font_color", Color.BLACK)

		var l_name := _add_label(row, d.name, Vector2(26, 1), Vector2(112, 16), 11)
		l_name.add_theme_color_override("font_color", Color.BLACK)

		var l_users := _add_label(row, "Users: %d" % d.users, Vector2(26, 14), Vector2(112, 14), 9)
		l_users.add_theme_color_override("font_color", Color8(60, 60, 60))

		rank_vbox.add_child(row)

func _build_con_notifications() -> void:
	con_notifications = DraggableWindow.new()
	con_notifications.size = Vector2(235, 314)
	can_main.add_child(con_notifications)

	var bryan := TextureRect.new()
	bryan.texture = tex_bryan
	bryan.position = Vector2(14, 17)
	bryan.size = Vector2(46, 99)
	bryan.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_notifications.add_child(bryan)

	notif_lbl = RichTextLabel.new()
	notif_lbl.position = Vector2(64, 17)
	notif_lbl.size = Vector2(157, 277)
	notif_lbl.add_theme_font_size_override("normal_font_size", 10)
	notif_lbl.add_theme_color_override("default_color", Color.WHITE)
	con_notifications.add_child(notif_lbl)

func _refresh_notifications() -> void:
	var lines: PackedStringArray = []
	for i in range(GameManager.msg_text.size() - 1, -1, -1):
		var d_str := GameManager.format_date(GameManager.msg_date[i])
		lines.append("[%s] - %s" % [d_str, GameManager.msg_text[i]])
	notif_lbl.text = "\n\n".join(lines)

func _build_con_package_selection() -> void:
	con_package_selection = DraggableWindow.new()
	con_package_selection.size = Vector2(600, 450)
	can_main.add_child(con_package_selection)

	_add_label(con_package_selection, "Package Selection", Vector2(15, 12), Vector2(200, 20), 13)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 35)
	bg.size = Vector2(570, 360) 
	con_package_selection.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(15, 35)
	scroll.size = Vector2(570, 360) 
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_package_selection.add_child(scroll)

	pkg_vbox = VBoxContainer.new()
	pkg_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pkg_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(pkg_vbox)

	var btn_ok := _add_button(con_package_selection, "OK!", Vector2(515, 405), Vector2(70, 30))
	btn_ok.pressed.connect(_on_package_selection_ok)

func _refresh_package_selection() -> void:
	for child in pkg_vbox.get_children():
		child.queue_free()

	for i in range(GameManager.packages_available.size()):
		var p := GameManager.packages_available[i]
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(550, 60)
		row.color = Color.WHITE if i % 2 == 0 else Color8(242, 242, 242)

		var chk := CheckBox.new()
		chk.position = Vector2(10, 16)
		chk.size = Vector2(24, 24) 
		chk.button_pressed = GameManager.my_distro.is_package_in_distro(i)
		var pkg_idx := i
		chk.toggled.connect(func(pressed: bool):
			if pressed:
				GameManager.my_distro.add_package_to_distro(pkg_idx)
			else:
				GameManager.my_distro.remove_package_from_distro(pkg_idx)
		)
		row.add_child(chk)

		var title := "%s %d.0 - %s" % [p.name, p.version, p.get_category_name()]
		var l_title := _add_label(row, title, Vector2(50, 6), Vector2(490, 16), 13)
		l_title.add_theme_color_override("font_color", Color.BLACK)

		var l_desc := _add_label(row, p.description, Vector2(50, 22), Vector2(490, 16), 11)
		l_desc.add_theme_color_override("font_color", Color8(50, 50, 50))

		var os_txt := "Yes" if p.is_open_source else "No"
		var stats_line := "OpenSource: %s    Nerd Cred: %d    Popularity: %d    Size(MB): %d    Bugs: %d" % [
			os_txt, p.nerd_cred, p.popularity, p.size_in_mb, p.bugs
		]
		var l_stats := _add_label(row, stats_line, Vector2(50, 38), Vector2(490, 14), 10)
		l_stats.add_theme_color_override("font_color", Color8(80, 80, 80))

		pkg_vbox.add_child(row)

func _on_package_selection_ok() -> void:
	con_package_selection.visible = false
	con_distro_stats.visible = true
	_refresh_distro_stats()

	if GameManager.is_first_run:
		intro_step = 2
		con_intro.position = Vector2(con_distro_stats.position.x + con_distro_stats.size.x + 20, con_distro_stats.position.y)
		stats_btn_packages.disabled = true
		stats_btn_release.disabled = true
		stats_btn_workers.disabled = true
		intro_btn_next.text = "Get Started"
		intro_lbl.text = "On the left you'll find a summary of the version of your Linux Distro that is currently \"in development\".\n\nOnce you are satisfied with this version you can click \"Release Version\" to make this version public (and people will then be able to use it).\n\nAs soon as you release your first version, time will start moving."
		con_intro.visible = true
	elif GameManager.my_distro.released_ver > 0:
		unpause_game()
		show_main_hud()

func _build_con_worker_assignment() -> void:
	con_worker_assignment = DraggableWindow.new()
	con_worker_assignment.size = Vector2(464, 294)
	can_main.add_child(con_worker_assignment)

	_add_label(con_worker_assignment, "Worker Assignment", Vector2(12, 11), Vector2(149, 20), 11)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(12, 33)
	bg.size = Vector2(184, 247)
	con_worker_assignment.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 33)
	scroll.size = Vector2(184, 247)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_worker_assignment.add_child(scroll)

	work_list_vbox = VBoxContainer.new()
	work_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	work_list_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(work_list_vbox)

	_add_label(con_worker_assignment, "Available Paid Workers :", Vector2(208, 33), Vector2(168, 20), 11)
	work_lbl_avail_paid = _add_label(con_worker_assignment, "0 / 0", Vector2(377, 33), Vector2(67, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_worker_assignment, "Available Volunteers :", Vector2(208, 65), Vector2(168, 20), 11)
	work_lbl_avail_vol = _add_label(con_worker_assignment, "0 / 0", Vector2(377, 65), Vector2(67, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	work_lbl_pkg_name = _add_label(con_worker_assignment, "", Vector2(208, 120), Vector2(240, 20), 12)

	_add_label(con_worker_assignment, "Paid Workers", Vector2(220, 156), Vector2(115, 20), 11)
	work_lbl_assign_paid = _add_label(con_worker_assignment, "0", Vector2(335, 156), Vector2(50, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)
	var btn_p_minus := _add_button(con_worker_assignment, "-", Vector2(395, 154), Vector2(24, 22))
	var btn_p_plus := _add_button(con_worker_assignment, "+", Vector2(423, 154), Vector2(24, 22))

	btn_p_minus.pressed.connect(func():
		var d := GameManager.my_distro
		if work_selected_idx < d.workers_paid_assigned.size() and d.workers_paid_assigned[work_selected_idx] > 0:
			d.workers_paid_assigned[work_selected_idx] -= 1
			_refresh_worker_assignment()
	)
	btn_p_plus.pressed.connect(func():
		var d := GameManager.my_distro
		if work_selected_idx < d.workers_paid_assigned.size() and d.get_distro_worker_available_paid() > 0:
			d.workers_paid_assigned[work_selected_idx] += 1
			_refresh_worker_assignment()
	)

	_add_label(con_worker_assignment, "Volunteers", Vector2(220, 188), Vector2(115, 20), 11)
	work_lbl_assign_vol = _add_label(con_worker_assignment, "0", Vector2(335, 188), Vector2(50, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)
	var btn_v_minus := _add_button(con_worker_assignment, "-", Vector2(395, 186), Vector2(24, 22))
	var btn_v_plus := _add_button(con_worker_assignment, "+", Vector2(423, 186), Vector2(24, 22))

	btn_v_minus.pressed.connect(func():
		var d := GameManager.my_distro
		if work_selected_idx < d.workers_volunteers_assigned.size() and d.workers_volunteers_assigned[work_selected_idx] > 0:
			d.workers_volunteers_assigned[work_selected_idx] -= 1
			_refresh_worker_assignment()
	)
	btn_v_plus.pressed.connect(func():
		var d := GameManager.my_distro
		if work_selected_idx < d.workers_volunteers_assigned.size() and d.get_distro_worker_available_volunteer() > 0:
			d.workers_volunteers_assigned[work_selected_idx] += 1
			_refresh_worker_assignment()
	)

	var btn_sac := _add_button(con_worker_assignment, "Sacrifice Worker", Vector2(252, 252), Vector2(120, 22))
	btn_sac.pressed.connect(func():
		con_worker_assignment.visible = false
		center_container(con_sacrifice_worker)
		_refresh_sacrifice_worker()
		con_sacrifice_worker.visible = true
	)

	var btn_ok := _add_button(con_worker_assignment, "OK!", Vector2(384, 252), Vector2(67, 22))
	btn_ok.pressed.connect(func():
		con_worker_assignment.visible = false
		unpause_game()
		show_main_hud()
	)

func _refresh_worker_assignment() -> void:
	for child in work_list_vbox.get_children():
		child.queue_free()

	var d := GameManager.my_distro
	if d.packages_included.is_empty():
		return

	work_selected_idx = clampi(work_selected_idx, 0, d.packages_included.size() - 1)

	for i in range(d.packages_included.size()):
		var pkg_idx := d.packages_included[i]
		var p := GameManager.packages_available[pkg_idx]

		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(174, 36)
		row.color = Color8(205, 225, 255) if i == work_selected_idx else (Color.WHITE if i % 2 == 0 else Color8(242, 242, 242))

		var l_title := _add_label(row, "%s %d.0" % [p.name, p.version], Vector2(4, 2), Vector2(166, 16), 11)
		l_title.add_theme_color_override("font_color", Color.BLACK)

		var sub := "Bugs: %d  Vol: %d  Paid: %d" % [p.bugs, d.workers_volunteers_assigned[i], d.workers_paid_assigned[i]]
		var l_sub := _add_label(row, sub, Vector2(4, 18), Vector2(166, 14), 9)
		l_sub.add_theme_color_override("font_color", Color8(70, 70, 70))

		var click_btn := Button.new()
		click_btn.flat = true
		click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var idx_capture := i
		click_btn.pressed.connect(func():
			work_selected_idx = idx_capture
			_refresh_worker_assignment()
		)
		row.add_child(click_btn)
		work_list_vbox.add_child(row)

	work_lbl_avail_paid.text = "%d / %d" % [d.get_distro_worker_available_paid(), d.workers_paid]
	work_lbl_avail_vol.text = "%d / %d" % [d.get_distro_worker_available_volunteer(), d.workers_volunteers]

	var sel_pkg := GameManager.packages_available[d.packages_included[work_selected_idx]]
	work_lbl_pkg_name.text = sel_pkg.name
	work_lbl_assign_paid.text = str(d.workers_paid_assigned[work_selected_idx])
	work_lbl_assign_vol.text = str(d.workers_volunteers_assigned[work_selected_idx])

func _build_con_sacrifice_worker() -> void:
	con_sacrifice_worker = DraggableWindow.new()
	con_sacrifice_worker.size = Vector2(332, 211)
	can_main.add_child(con_sacrifice_worker)

	var desc := _add_label(con_sacrifice_worker, "You may sacrifice volunteers for immediate, but highly mysterious, boosts.", Vector2(20, 14), Vector2(292, 45), 11)
	desc.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	_add_label(con_sacrifice_worker, "Available Volunteers :", Vector2(20, 71), Vector2(168, 20), 11)
	sac_lbl_avail = _add_label(con_sacrifice_worker, "0 / 0", Vector2(189, 71), Vector2(67, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	var btn_boost := _add_button(con_sacrifice_worker, "Sacrifice Worker", Vector2(106, 103), Vector2(120, 22))
	btn_boost.pressed.connect(func():
		var d := GameManager.my_distro
		if d.get_distro_worker_available_volunteer() > 0:
			d.workers_volunteers -= 1
			var hype_change := randi_range(-5, 15)
			var user_change := randi_range(-30, 65)
			d.hype += hype_change
			d.users = maxi(0, d.users + user_change)

			var u_str := ("+" + str(user_change)) if user_change > -1 else str(user_change)
			var h_str := ("+" + str(hype_change)) if hype_change > -1 else str(hype_change)
			sac_lbl_results.text = "Users: %s    Hype: %s" % [u_str, h_str]
			_refresh_sacrifice_worker()
			GameManager.stats_updated.emit()
	)

	sac_lbl_results = _add_label(con_sacrifice_worker, "", Vector2(20, 137), Vector2(292, 20), 11, HORIZONTAL_ALIGNMENT_CENTER)

	var btn_ok := _add_button(con_sacrifice_worker, "No more!", Vector2(85, 169), Vector2(162, 22))
	btn_ok.pressed.connect(func():
		con_sacrifice_worker.visible = false
		_refresh_worker_assignment()
		con_worker_assignment.visible = true
	)

func _refresh_sacrifice_worker() -> void:
	var d := GameManager.my_distro
	sac_lbl_avail.text = "%d / %d" % [d.get_distro_worker_available_volunteer(), d.workers_volunteers]

func _build_con_new_release() -> void:
	con_new_release = DraggableWindow.new()
	con_new_release.size = Vector2(390, 170)
	can_main.add_child(con_new_release)

	var bryan := TextureRect.new()
	bryan.texture = tex_bryan
	bryan.position = Vector2(14, 17)
	bryan.size = Vector2(46, 99)
	bryan.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_new_release.add_child(bryan)

	release_lbl_text = _add_label(con_new_release, "", Vector2(72, 17), Vector2(304, 99), 11)
	release_lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var btn_ok := _add_button(con_new_release, "OK!", Vector2(303, 128), Vector2(67, 22))
	btn_ok.pressed.connect(_on_new_release_ok_clicked)

func _build_dialogs() -> void:
	confirm_release_dlg = ConfirmationDialog.new()
	confirm_release_dlg.title = "Release Version"
	confirm_release_dlg.dialog_text = "Are you ready to release this version?\nYou won't be able to change any packages or fix any bugs in this version once it is released."
	confirm_release_dlg.ok_button_text = "Yes"
	confirm_release_dlg.cancel_button_text = "No"
	confirm_release_dlg.confirmed.connect(_on_release_version_confirmed)
	confirm_release_dlg.canceled.connect(unpause_game)
	add_child(confirm_release_dlg)

	file_dlg_save = FileDialog.new()
	file_dlg_save.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dlg_save.access = FileDialog.ACCESS_USERDATA
	file_dlg_save.current_file = "SaveGame.lts"
	file_dlg_save.add_filter("*.lts ; Linux Tycoon Save Game")
	file_dlg_save.canceled.connect(unpause_game)
	file_dlg_save.file_selected.connect(func(path: String):
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(GameManager.generate_save_xml())
			f.close()
		unpause_game() 
	)
	add_child(file_dlg_save)

	file_dlg_load = FileDialog.new()
	file_dlg_load.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dlg_load.access = FileDialog.ACCESS_USERDATA
	file_dlg_load.add_filter("*.lts ; Linux Tycoon Save Game")
	file_dlg_load.canceled.connect(unpause_game)
	file_dlg_load.file_selected.connect(func(path: String):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var xml := f.get_as_text()
			f.close()
			if GameManager.load_xml_string(xml, true):
				_hide_all_containers()
				unpause_game()
				show_main_hud()
				_refresh_notifications()
		else:
			unpause_game()
	)
	add_child(file_dlg_load)

	file_dlg_scenario = FileDialog.new()
	file_dlg_scenario.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dlg_scenario.access = FileDialog.ACCESS_FILESYSTEM
	file_dlg_scenario.add_filter("*.ltx ; Linux Tycoon Scenario")
	file_dlg_scenario.canceled.connect(unpause_game)
	file_dlg_scenario.file_selected.connect(func(path: String):
		var f := FileAccess.open(path, FileAccess.READ)
		if f:
			var xml := f.get_as_text()
			f.close()
			GameManager.load_xml_string(xml, false)
		unpause_game()
	)
	add_child(file_dlg_scenario)

# --- UI HELPERS ---

func _add_label(parent: Control, text: String, pos: Vector2, sz: Vector2, font_sz: int = 11, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_LEFT) -> Label:
	var l := Label.new()
	l.text = text
	l.position = pos
	l.size = sz
	l.horizontal_alignment = align
	l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	l.add_theme_font_size_override("font_size", font_sz)
	parent.add_child(l)
	return l

func _add_button(parent: Control, text: String, pos: Vector2, sz: Vector2) -> Button:
	var b := Button.new()
	b.text = text
	b.position = pos
	b.size = sz
	parent.add_child(b)
	return b

func _setup_initial_positions() -> void:
	var w := size.x if size.x > 0 else 620.0
	con_distro_stats.position = Vector2(5, 5)
	con_overview.position = Vector2(w - con_overview.size.x - 5, 5)
	con_distro_rank.position = Vector2(w - con_distro_rank.size.x - 5, 68)
	con_notifications.position = Vector2(con_overview.position.x, 68)

	for centered in [con_main_menu, con_intro, con_package_selection, con_worker_assignment, con_sacrifice_worker, con_new_release]:
		center_container(centered)

func center_container(ctrl: Control) -> void:
	var w := size.x if size.x > 0 else 620.0
	var h := (size.y - 22.0) if size.y > 22.0 else 388.0
	ctrl.position = Vector2(roundf((w - ctrl.size.x) / 2.0), roundf((h - ctrl.size.y) / 2.0))

func _hide_all_containers() -> void:
	for child in can_main.get_children():
		if child is Control:
			child.visible = false

func pause_game() -> void:
	day_timer.stop()
	btn_pause.visible = false

func unpause_game() -> void:
	day_timer.start()
	btn_pause.visible = true

func _on_btn_pause_pressed() -> void:
	if btn_pause.text == "||":
		GameManager.is_paused = true
		btn_pause.text = ">"
	else:
		GameManager.is_paused = false
		btn_pause.text = "||"

func _on_day_timer_timeout() -> void:
	if not GameManager.is_paused:
		GameManager.increment_by_a_day()

func _on_stats_updated() -> void:
	lbl_date.text = GameManager.format_date(GameManager.the_date)
	if con_distro_stats.visible:
		_refresh_distro_stats()
	if con_overview.visible:
		_refresh_overview()
	if con_distro_rank.visible:
		_refresh_distro_rank()

func _on_message_added(_msg: String, _date: int) -> void:
	_refresh_notifications()

func show_main_hud() -> void:
	con_distro_stats.visible = true
	con_distro_rank.visible = true
	con_overview.visible = true
	con_notifications.visible = true
	_on_stats_updated()

func _on_release_version_confirmed() -> void:
	pause_game()
	_hide_all_containers()
	release_lbl_text.text = "%s version %d.0 has been successfully released to the public!\n\nNow just sit back and let the fame and riches pour in! (Or get to work on the next version.)" % [
		GameManager.my_distro.name, GameManager.my_distro.version
	]
	center_container(con_new_release)
	con_new_release.visible = true

func _on_new_release_ok_clicked() -> void:
	GameManager.my_distro.release_new_version()
	unpause_game()
	con_new_release.visible = false
	show_main_hud()
	GameManager.show_message("%s version %d.0 released!" % [GameManager.my_distro.name, GameManager.my_distro.released_ver])