extends Control

var day_timer: Timer
var sys_timer: Timer 
var lbl_date: Label
var lbl_sys_time: Label 
var btn_pause: Button
var lbl_paused: Label
var btn_settings_top: Button 
var btn_close_top: Button
var can_main: Control

var sys_time_format: int = 1

var audio_player: AudioStreamPlayer
var playlist: Array[Dictionary] = []
var current_track_idx: int = 0
var is_muted: bool = false
var music_volume: float = 50.0

var btn_skip_prev: Button
var btn_skip_next: Button
var btn_mute: Button
var lbl_mp3: Label
var chk_mute: CheckBox 

var btn_mp3_player: Button 
var con_mp3_player: DraggableWindow 
var playlist_vbox: VBoxContainer 

# --- NEW: Global references for the Jukebox controls ---
var btn_mp3_play: Button
var btn_mp3_pause: Button
var btn_mp3_stop: Button
var btn_mp3_shuf: Button
# -------------------------------------------------------

var tex_list: Texture2D
var tex_shuffle: Texture2D
var tex_stop: Texture2D
var tex_music_note: Texture2D # NEW: Music note icon for the MP3 ticker
var mp3_icon: TextureRect

var is_mp3_playing: bool = true 
var is_mp3_paused: bool = false # NEW: Tracks stream suspension
var is_shuffled: bool = true

var tex_save_as: Texture2D
var btn_save_as_top: Button
var con_confirm_save: DraggableWindow
var current_save_path: String = "user://SaveGame.lts"

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
var con_settings: DraggableWindow
var con_confirm_release: DraggableWindow 
var con_confirm_quit: DraggableWindow 
var con_confirm_desktop: DraggableWindow
var con_credits: DraggableWindow
var con_license: DraggableWindow
var con_music: DraggableWindow

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

var show_mp3_player: bool = true
var mp3_bg: ColorRect

var rank_vbox: VBoxContainer
var notif_lbl: RichTextLabel
var pkg_vbox: VBoxContainer
var pkg_sort_mode: int = 0

var work_list_vbox: VBoxContainer
var work_selected_idx: int = 0
var work_sort_mode: int = 0 # NEW: Tracks the Worker Assignment sort mode
var work_lbl_avail_paid: Label
var work_lbl_avail_vol: Label
var work_lbl_pkg_name: Label
var work_lbl_assign_paid: Label
var work_lbl_assign_vol: Label

var sac_lbl_avail: Label
var sac_lbl_results: Label
var release_lbl_text: Label

var file_dlg_save: FileDialog
var file_dlg_load: FileDialog
var file_dlg_scenario: FileDialog

var tex_tux: Texture2D
var tex_bryan: Texture2D
var tex_pause: Texture2D
var tex_play: Texture2D
var tex_settings: Texture2D
var tex_close: Texture2D
var tex_skip_prev: Texture2D
var tex_skip_next: Texture2D
var tex_mute: Texture2D
var tex_volume_up: Texture2D
var tex_add: Texture2D
var tex_remove: Texture2D

var bryan_new_release: TextureRect
var btn_ok_new_release: Button

func _ready() -> void:
	if ResourceLoader.exists("res://Tux32x32.png"):
		tex_tux = load("res://Tux32x32.png")
	if ResourceLoader.exists("res://Bryan.png"):
		tex_bryan = load("res://Bryan.png")
		
	if ResourceLoader.exists("res://icons/pause_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_pause = load("res://icons/pause_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/play_arrow_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_play = load("res://icons/play_arrow_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/settings_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_settings = load("res://icons/settings_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/close_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_close = load("res://icons/close_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/save_as_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_save_as = load("res://icons/save_as_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
		
	if ResourceLoader.exists("res://icons/skip_previous_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_skip_prev = load("res://icons/skip_previous_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/skip_next_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_skip_next = load("res://icons/skip_next_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/volume_off_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_mute = load("res://icons/volume_off_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/volume_up_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_volume_up = load("res://icons/volume_up_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
		
	if ResourceLoader.exists("res://icons/add_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_add = load("res://icons/add_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/remove_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_remove = load("res://icons/remove_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")

	if ResourceLoader.exists("res://icons/list_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_list = load("res://icons/list_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/stop_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_stop = load("res://icons/stop_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/shuffle_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png"):
		tex_shuffle = load("res://icons/shuffle_18dp_E3E3E3_FILL1_wght700_GRAD0_opsz20.png")
	if ResourceLoader.exists("res://icons/music_note_2_18dp_E3E3E3_FILL1_wght400_GRAD0_opsz20.png"):
		tex_music_note = load("res://icons/music_note_2_18dp_E3E3E3_FILL1_wght400_GRAD0_opsz20.png")

	audio_player = AudioStreamPlayer.new()
	add_child(audio_player)
	audio_player.finished.connect(_on_track_finished)
	
	_add_track("res://music/alex-morgan-downtempo-chill-electronic-528322.mp3", "Alex Morgan — Downtempo Chill Electronic")
	_add_track("res://music/amplify_music-jazz-cafe-music-electric-velvet-groove-337638.mp3", "Amplify Music — Jazz Cafe Music")
	_add_track("res://music/kulakovka-inspiring-downtempo-278455.mp3", "Kulakovka — Inspiring Downtempo")
	_add_track("res://music/soundsurfer-downtempo-613674.mp3", "Soundsurfer — Downtempo")
	_add_track("res://music/turning_pages-kindling-the-flame-479806.mp3", "Turning Pages — Kindling The Flame")
	_add_track("res://music/alex-morgan-acid-jazz-cafe-lounge-groove-573653.mp3", "Alex Morgan — Acid Jazz Cafe")
	_add_track("res://music/tunetank-inspiring-downtempo-348057.mp3", "Tunetank — Inspiring Downtempo")
	_add_track("res://music/pavetraxx-digital-beauty-264973.mp3", "Pavetraxx — Digital Beauty")
	_add_track("res://music/sergepavkinmusic-looking-at-the-horizon-148802.mp3", "Serge Pavkin — Looking at the Horizon")
	_add_track("res://music/tunetank-downtempo-beat-347779.mp3", "Tunetank — Downtempo Beat") # NEW: Track 10
	
	playlist.shuffle()

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
	_build_con_settings()
	_build_con_confirm_release() 
	_build_con_confirm_quit()
	_build_con_confirm_desktop()
	_build_con_confirm_save()
	_build_con_credits()
	_build_con_music()
	_build_con_mp3_player()
	_build_con_license()
	_build_dialogs()

	GameManager.stats_updated.connect(_on_stats_updated)
	GameManager.message_added.connect(_on_message_added)
	GameManager.scenario_loaded.connect(func(s_name: String): lbl_scenario.text = "Scenario: " + s_name)

	resized.connect(_setup_initial_positions)
	_setup_initial_positions()
	_hide_all_containers()
	con_main_menu.visible = true
	
	pause_game() 
	lbl_date.text = ""
	
	if playlist.size() > 0:
		_play_track(0)
		_update_volume()

func _add_track(path: String, title: String) -> void:
	if ResourceLoader.exists(path):
		var stream = load(path)
		# NEW: Added "enabled" state
		playlist.append({"stream": stream, "title": title, "enabled": true})

func _play_track(idx: int) -> void:
	if playlist.is_empty():
		return

	# Prevent infinite loops if everything is disabled
	var any_enabled := false
	for track in playlist:
		if track["enabled"]:
			any_enabled = true
			break
	if not any_enabled:
		audio_player.stop()
		is_mp3_playing = false
		is_mp3_paused = false
		audio_player.stream_paused = false
		if lbl_mp3 != null:
			lbl_mp3.text = "No Tracks Enabled"
		_sync_mp3_ui()
		if playlist_vbox != null:
			_refresh_mp3_list()
		return

	# Loop forward until we find an enabled track
	var attempts := 0
	current_track_idx = posmod(idx, playlist.size())
	while not playlist[current_track_idx]["enabled"] and attempts < playlist.size():
		current_track_idx = posmod(current_track_idx + 1, playlist.size())
		attempts += 1

	var track = playlist[current_track_idx]
	
	# Purge the engine lockup state before assigning a new track
	audio_player.stream_paused = false 
	audio_player.stream = track["stream"]
	
	if is_mp3_playing:
		audio_player.play()
		if is_mp3_paused:
			audio_player.stream_paused = true
	else:
		audio_player.stop()
		
	if lbl_mp3 != null:
		lbl_mp3.text = track["title"]
		
	_sync_mp3_ui()

	if playlist_vbox != null:
		_refresh_mp3_list()

func _on_track_finished() -> void:
	_play_track(current_track_idx + 1)

func _update_volume() -> void:
	if audio_player == null: return
	if is_muted or music_volume <= 0.0:
		audio_player.volume_db = -80.0
	else:
		audio_player.volume_db = linear_to_db(music_volume / 100.0)
		
func _on_mute_toggled() -> void:
	is_muted = !is_muted
	btn_mute.icon = tex_mute if is_muted else tex_volume_up
	_set_desktop_tooltip(btn_mute, "Unmute Music" if is_muted else "Mute Music")
	if chk_mute != null:
		chk_mute.set_pressed_no_signal(is_muted)
	_update_volume()

func _update_mp3_visibility() -> void:
	if btn_mp3_player != null: btn_mp3_player.visible = show_mp3_player
	if btn_skip_prev != null: btn_skip_prev.visible = show_mp3_player
	if btn_skip_next != null: btn_skip_next.visible = show_mp3_player
	if btn_mute != null: btn_mute.visible = show_mp3_player
	if mp3_bg != null: mp3_bg.visible = show_mp3_player

func _sync_mp3_ui() -> void:
	if btn_mp3_play != null:
		btn_mp3_play.disabled = (is_mp3_playing and not is_mp3_paused)
		btn_mp3_play.modulate = Color(0.5, 0.5, 0.5, 1.0) if btn_mp3_play.disabled else Color.WHITE
		
		btn_mp3_pause.disabled = (not is_mp3_playing or is_mp3_paused)
		btn_mp3_pause.modulate = Color(0.5, 0.5, 0.5, 1.0) if btn_mp3_pause.disabled else Color.WHITE
		
		btn_mp3_stop.disabled = not is_mp3_playing
		btn_mp3_stop.modulate = Color(0.5, 0.5, 0.5, 1.0) if btn_mp3_stop.disabled else Color.WHITE
		
		btn_mp3_shuf.modulate = Color.WHITE if is_shuffled else Color(0.5, 0.5, 0.5, 1.0)

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
	
	var sb_window := StyleBoxFlat.new()
	sb_window.bg_color = Color8(180, 198, 228) 
	sb_window.border_color = Color8(60, 107, 173) 
	sb_window.set_border_width_all(4)
	t.set_stylebox("panel", "Window", sb_window)
	
	var sb_embedded := sb_window.duplicate()
	sb_embedded.expand_margin_top = 28 
	t.set_stylebox("embedded_border", "Window", sb_embedded)
	t.set_stylebox("embedded_unfocused_border", "Window", sb_embedded)
	
	var sb_inner := StyleBoxFlat.new()
	sb_inner.bg_color = Color8(89, 131, 192) 
	sb_inner.border_color = Color8(60, 107, 173)
	sb_inner.set_border_width_all(1)
	t.set_stylebox("panel", "Tree", sb_inner)
	t.set_stylebox("panel", "ItemList", sb_inner)
	
	t.set_color("font_color", "Tree", Color.WHITE)
	t.set_color("font_color", "ItemList", Color.WHITE)
	t.set_color("title_color", "Window", Color.BLACK)
	t.set_font_size("title_font_size", "Window", 13)

	var sb_tooltip := _make_btn_style(Color.BLACK, Color.BLACK)
	sb_tooltip.content_margin_left = 8
	sb_tooltip.content_margin_right = 8
	sb_tooltip.content_margin_top = 4
	sb_tooltip.content_margin_bottom = 4
	t.set_stylebox("panel", "TooltipPanel", sb_tooltip)
	t.set_color("font_color", "TooltipLabel", Color.WHITE)
	t.set_font_size("font_size", "TooltipLabel", 11)

	theme = t

func _set_desktop_tooltip(ctrl: Control, tip: String) -> void:
	if OS.get_name() in ["Windows", "macOS", "Linux", "FreeBSD", "NetBSD", "OpenBSD", "BSD"]:
		ctrl.tooltip_text = tip

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
	top_bar.offset_bottom = 26 
	add_child(top_bar)
	
	lbl_sys_time = Label.new()
	lbl_sys_time.anchor_left = 0.0
	lbl_sys_time.anchor_right = 0.0
	lbl_sys_time.offset_left = 5 
	lbl_sys_time.offset_right = 85
	lbl_sys_time.offset_top = 2
	lbl_sys_time.offset_bottom = 24
	lbl_sys_time.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	lbl_sys_time.add_theme_color_override("font_color", Color.BLACK)
	lbl_sys_time.visible = false
	top_bar.add_child(lbl_sys_time)

	lbl_date = Label.new()
	lbl_date.anchor_left = 0.0
	lbl_date.anchor_right = 0.5
	lbl_date.offset_left = 85
	lbl_date.offset_right = -200 
	lbl_date.offset_top = 2
	lbl_date.offset_bottom = 24
	lbl_date.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_date.add_theme_color_override("font_color", Color.BLACK)
	lbl_date.visible = false
	top_bar.add_child(lbl_date)

	lbl_paused = Label.new()
	lbl_paused.anchor_left = 1.0
	lbl_paused.anchor_right = 1.0
	lbl_paused.offset_left = -210
	lbl_paused.offset_right = -150 
	lbl_paused.offset_top = 2
	lbl_paused.offset_bottom = 24
	lbl_paused.text = "Paused"
	lbl_paused.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	lbl_paused.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_paused.add_theme_color_override("font_color", Color.BLACK)
	lbl_paused.add_theme_font_size_override("font_size", 13)
	lbl_paused.visible = false
	top_bar.add_child(lbl_paused)

	var sb_icon_btn := StyleBoxFlat.new()
	sb_icon_btn.bg_color = Color8(89, 131, 192)
	sb_icon_btn.border_color = Color8(60, 107, 173)
	sb_icon_btn.set_border_width_all(1)
	
	var sb_icon_hover := sb_icon_btn.duplicate()
	sb_icon_hover.bg_color = Color8(47, 92, 159)
	
	var sb_icon_pressed := sb_icon_btn.duplicate()
	sb_icon_pressed.bg_color = Color8(35, 75, 140)

	# MP3 Player List Button
	btn_mp3_player = Button.new()
	btn_mp3_player.anchor_left = 0.5
	btn_mp3_player.anchor_right = 0.5
	btn_mp3_player.offset_left = -200
	btn_mp3_player.offset_right = -170
	btn_mp3_player.offset_top = 2
	btn_mp3_player.offset_bottom = 24
	btn_mp3_player.icon = tex_list
	btn_mp3_player.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_mp3_player.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_mp3_player.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_mp3_player.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_mp3_player.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_mp3_player.pressed.connect(func():
		center_container(con_mp3_player)
		con_mp3_player.visible = true
		con_mp3_player.move_to_front()
	)
	top_bar.add_child(btn_mp3_player)

	# Previous Button
	btn_skip_prev = Button.new()
	btn_skip_prev.anchor_left = 0.5
	btn_skip_prev.anchor_right = 0.5
	btn_skip_prev.offset_left = -165
	btn_skip_prev.offset_right = -135
	btn_skip_prev.offset_top = 2
	btn_skip_prev.offset_bottom = 24
	btn_skip_prev.icon = tex_skip_prev
	btn_skip_prev.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_skip_prev.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_skip_prev.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_skip_prev.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_skip_prev.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_skip_prev.pressed.connect(func(): _play_track(current_track_idx - 1))
	top_bar.add_child(btn_skip_prev)

	mp3_bg = ColorRect.new()
	mp3_bg.color = Color.BLACK
	mp3_bg.anchor_left = 0.5
	mp3_bg.anchor_right = 0.5
	mp3_bg.offset_left = -130
	mp3_bg.offset_right = 130
	mp3_bg.offset_top = 2
	mp3_bg.offset_bottom = 24
	top_bar.add_child(mp3_bg)

	var mp3_hbox := HBoxContainer.new()
	mp3_hbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	mp3_hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	mp3_hbox.add_theme_constant_override("separation", 4)
	mp3_bg.add_child(mp3_hbox)

	mp3_icon = TextureRect.new()
	mp3_icon.texture = tex_music_note
	mp3_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	mp3_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	mp3_icon.custom_minimum_size = Vector2(12, 12) # Scaled down to match 11pt text
	mp3_icon.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	mp3_icon.modulate = Color.GREEN
	mp3_hbox.add_child(mp3_icon)

	lbl_mp3 = Label.new()
	lbl_mp3.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	lbl_mp3.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	lbl_mp3.add_theme_color_override("font_color", Color.GREEN)
	lbl_mp3.add_theme_font_size_override("font_size", 11)
	lbl_mp3.text = "Artist — Song Name"
	mp3_hbox.add_child(lbl_mp3)

	# Next Button
	btn_skip_next = Button.new()
	btn_skip_next.anchor_left = 0.5
	btn_skip_next.anchor_right = 0.5
	btn_skip_next.offset_left = 135
	btn_skip_next.offset_right = 165
	btn_skip_next.offset_top = 2
	btn_skip_next.offset_bottom = 24
	btn_skip_next.icon = tex_skip_next
	btn_skip_next.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_skip_next.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_skip_next.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_skip_next.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_skip_next.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_skip_next.pressed.connect(func(): _play_track(current_track_idx + 1))
	top_bar.add_child(btn_skip_next)

	btn_mute = Button.new()
	btn_mute.anchor_left = 0.5
	btn_mute.anchor_right = 0.5
	btn_mute.offset_left = 170
	btn_mute.offset_right = 200
	btn_mute.offset_top = 2
	btn_mute.offset_bottom = 24
	btn_mute.icon = tex_volume_up
	btn_mute.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_mute.expand_icon = true
	btn_mute.add_theme_constant_override("icon_max_width", 14) 
	btn_mute.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_mute.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_mute.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_mute.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_mute.pressed.connect(_on_mute_toggled)
	top_bar.add_child(btn_mute)

	btn_pause = Button.new()
	btn_pause.anchor_left = 1.0
	btn_pause.anchor_right = 1.0
	btn_pause.offset_left = -140
	btn_pause.offset_right = -110
	btn_pause.offset_top = 2
	btn_pause.offset_bottom = 24
	btn_pause.icon = tex_pause
	btn_pause.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_pause.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_pause.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_pause.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_pause.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_pause.visible = false
	btn_pause.pressed.connect(_on_btn_pause_pressed)
	top_bar.add_child(btn_pause)

	btn_save_as_top = Button.new()
	btn_save_as_top.anchor_left = 1.0
	btn_save_as_top.anchor_right = 1.0
	btn_save_as_top.offset_left = -105
	btn_save_as_top.offset_right = -75
	btn_save_as_top.offset_top = 2
	btn_save_as_top.offset_bottom = 24
	btn_save_as_top.icon = tex_save_as
	btn_save_as_top.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_save_as_top.expand_icon = true
	btn_save_as_top.add_theme_constant_override("icon_max_width", 16)
	btn_save_as_top.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_save_as_top.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_save_as_top.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_save_as_top.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_save_as_top.visible = false
	btn_save_as_top.pressed.connect(func():
		pause_game()
		file_dlg_save.popup_centered()
	)
	top_bar.add_child(btn_save_as_top)

	btn_settings_top = Button.new()
	btn_settings_top.anchor_left = 1.0
	btn_settings_top.anchor_right = 1.0
	btn_settings_top.offset_left = -70 
	btn_settings_top.offset_right = -40
	btn_settings_top.offset_top = 2
	btn_settings_top.offset_bottom = 24
	btn_settings_top.icon = tex_settings
	btn_settings_top.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	btn_settings_top.add_theme_stylebox_override("normal", sb_icon_btn)
	btn_settings_top.add_theme_stylebox_override("hover", sb_icon_hover)
	btn_settings_top.add_theme_stylebox_override("pressed", sb_icon_pressed)
	btn_settings_top.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_settings_top.visible = true
	btn_settings_top.pressed.connect(func():
		center_container(con_settings)
		con_settings.visible = true
		con_settings.move_to_front()
	)
	top_bar.add_child(btn_settings_top)

	btn_close_top = Button.new()
	btn_close_top.anchor_left = 1.0
	btn_close_top.anchor_right = 1.0
	btn_close_top.offset_left = -35 
	btn_close_top.offset_right = -5
	btn_close_top.offset_top = 2
	btn_close_top.offset_bottom = 24
	btn_close_top.icon = tex_close
	btn_close_top.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var sb_close_btn := StyleBoxFlat.new()
	sb_close_btn.bg_color = Color("#be1616")
	sb_close_btn.border_color = Color("#8a1010")
	sb_close_btn.set_border_width_all(1)
	
	var sb_close_hover := sb_close_btn.duplicate()
	sb_close_hover.bg_color = Color("#d61c1c")
	
	var sb_close_pressed := sb_close_btn.duplicate()
	sb_close_pressed.bg_color = Color("#961212")
	
	btn_close_top.add_theme_stylebox_override("normal", sb_close_btn)
	btn_close_top.add_theme_stylebox_override("hover", sb_close_hover)
	btn_close_top.add_theme_stylebox_override("pressed", sb_close_pressed)
	btn_close_top.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn_close_top.visible = true
	btn_close_top.pressed.connect(func():
		pause_game()
		if con_main_menu.visible:
			center_container(con_confirm_desktop)
			con_confirm_desktop.visible = true
		else:
			center_container(con_confirm_quit)
			con_confirm_quit.visible = true
	)

	top_bar.add_child(btn_close_top)

	_set_desktop_tooltip(btn_mp3_player, "MP3 Player")
	_set_desktop_tooltip(btn_skip_prev, "Previous Track")
	_set_desktop_tooltip(btn_skip_next, "Next Track")
	_set_desktop_tooltip(btn_mute, "Mute Music")
	_set_desktop_tooltip(btn_pause, "Pause Game")
	_set_desktop_tooltip(btn_save_as_top, "Save Game As...")
	_set_desktop_tooltip(btn_settings_top, "Settings")
	_set_desktop_tooltip(btn_close_top, "Quit")

	can_main = Control.new()
	can_main.set_anchors_preset(Control.PRESET_FULL_RECT)
	can_main.offset_top = 26
	add_child(can_main)

	day_timer = Timer.new()
	day_timer.wait_time = 1.0
	day_timer.timeout.connect(_on_day_timer_timeout)
	add_child(day_timer)
	
	sys_timer = Timer.new()
	sys_timer.wait_time = 1.0
	sys_timer.autostart = true
	sys_timer.timeout.connect(_update_system_time)
	add_child(sys_timer)
	
	_update_system_time()

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
	_add_label(con_main_menu, "v?, derived from Linux Tycoon v1.1.2", Vector2(75, 75), Vector2(340, 22), 13)
	lbl_scenario = _add_label(con_main_menu, "Scenario: Standard", Vector2(75, 110), Vector2(340, 22), 13)
	
	var link_lunduke := LinkButton.new()
	link_lunduke.text = "https://www.Lunduke.com/"
	link_lunduke.position = Vector2(75, 145)
	link_lunduke.add_theme_font_size_override("font_size", 13)
	link_lunduke.add_theme_color_override("font_color", Color.WHITE)
	link_lunduke.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_lunduke.uri = "https://lunduke.com/"
	con_main_menu.add_child(link_lunduke)

	var support_lbl := _add_label(con_main_menu, "Support Bryan Lunduke by purchasing the\nLinux Tycoon Mega Collection for $12 on itch.io:", Vector2(75, 185), Vector2(330, 45), 13)
	support_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	support_lbl.vertical_alignment = VERTICAL_ALIGNMENT_TOP

	var link_itch := LinkButton.new()
	link_itch.text = "https://lunduke.itch.io/linux-tycoon-mega-collection/"
	link_itch.position = Vector2(75, 230)
	link_itch.add_theme_font_size_override("font_size", 13)
	link_itch.add_theme_color_override("font_color", Color.WHITE)
	link_itch.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_itch.uri = "https://lunduke.itch.io/linux-tycoon-mega-collection/"
	con_main_menu.add_child(link_itch)

	var redot_lbl := _add_label(con_main_menu, "Powered by Redot Engine v26.3:", Vector2(75, 350), Vector2(330, 45), 13)
	
	var link_redot := LinkButton.new()
	link_redot.text = "https://www.redotengine.org/"
	link_redot.position = Vector2(75, 385)
	link_redot.add_theme_font_size_override("font_size", 13)
	link_redot.add_theme_color_override("font_color", Color.WHITE)
	link_redot.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_redot.uri = "https://www.redotengine.org/"
	con_main_menu.add_child(link_redot)

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
	btn_settings.pressed.connect(func():
		center_container(con_settings)
		con_settings.visible = true
	)
	vbox.add_child(btn_settings)

	var btn_credits := Button.new()
	btn_credits.text = "Credits"
	btn_credits.pressed.connect(func():
		center_container(con_credits)
		con_credits.visible = true
	)
	vbox.add_child(btn_credits)

	var spacer := Control.new()
	spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.add_child(spacer)

	var btn_quit := Button.new()
	btn_quit.text = "Quit"
	btn_quit.pressed.connect(func(): 
		center_container(con_confirm_desktop)
		con_confirm_desktop.visible = true
	)
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
	con_distro_stats.size = Vector2(185, 464)
	can_main.add_child(con_distro_stats)

	stats_logo = TextureRect.new()
	stats_logo.texture = tex_tux
	stats_logo.position = Vector2(76, 13) 
	stats_logo.size = Vector2(32, 32)
	stats_logo.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_distro_stats.add_child(stats_logo)

	var lbl_dev := _add_label(con_distro_stats, "In Development", Vector2(20, 44), Vector2(145, 20), 10, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_dev.add_theme_color_override("font_color", Color8(229, 229, 229))

	stats_lbl_name = _add_label(con_distro_stats, "", Vector2(20, 63), Vector2(145, 20), 12, HORIZONTAL_ALIGNMENT_CENTER)
	stats_lbl_ver = _add_label(con_distro_stats, "Version 1.0", Vector2(20, 82), Vector2(145, 20), 11, HORIZONTAL_ALIGNMENT_CENTER)

	_add_label(con_distro_stats, "Hype :", Vector2(20, 106), Vector2(100, 20), 11)
	stats_lbl_hype = _add_label(con_distro_stats, "0", Vector2(80, 106), Vector2(85, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Bugs :", Vector2(20, 131), Vector2(100, 20), 11)
	stats_lbl_bugs = _add_label(con_distro_stats, "0", Vector2(80, 131), Vector2(85, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Size (MB) :", Vector2(20, 156), Vector2(100, 20), 11)
	stats_lbl_size = _add_label(con_distro_stats, "0", Vector2(120, 156), Vector2(45, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Volunteers :", Vector2(20, 182), Vector2(100, 20), 11)
	stats_lbl_vol = _add_label(con_distro_stats, "0 / 0", Vector2(100, 182), Vector2(65, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_distro_stats, "Paid Workers :", Vector2(20, 207), Vector2(100, 20), 11)
	stats_lbl_paid = _add_label(con_distro_stats, "0 / 0", Vector2(100, 207), Vector2(65, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	# Centered vertically between Paid Workers (y=227) and the inner bottom border (y=452)
	stats_btn_packages = _add_button(con_distro_stats, "Edit Packages", Vector2(20, 260), Vector2(145, 32))
	stats_btn_packages.pressed.connect(func():
		pause_game()
		_hide_all_containers()
		center_container(con_package_selection)
		_refresh_package_selection()
		con_package_selection.visible = true
	)

	stats_btn_workers = _add_button(con_distro_stats, "Assign Workers", Vector2(20, 302), Vector2(145, 32))
	stats_btn_workers.pressed.connect(func():
		pause_game()
		_hide_all_containers()
		work_selected_idx = 0
		center_container(con_worker_assignment)
		_refresh_worker_assignment()
		con_worker_assignment.visible = true
	)

	stats_btn_release = _add_button(con_distro_stats, "Release Version", Vector2(20, 344), Vector2(145, 32))
	stats_btn_release.pressed.connect(func(): 
		pause_game()
		center_container(con_confirm_release)
		for child in con_confirm_release.get_children():
			if child is CanvasItem:
				child.show()
		con_confirm_release.visible = true
	)

	stats_btn_save = _add_button(con_distro_stats, "Save", Vector2(20, 386), Vector2(145, 32))
	stats_btn_save.disabled = true
	stats_btn_save.pressed.connect(func(): 
		pause_game()
		center_container(con_confirm_save)
		con_confirm_save.visible = true
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
	con_overview.size = Vector2(650, 50) # Fits precisely between stats and right edge
	can_main.add_child(con_overview)

	var make_lbl = func(pos: Vector2, sz: Vector2) -> Label:
		var l := Label.new()
		l.position = pos
		l.size = sz
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		l.add_theme_font_size_override("font_size", 12) 
		con_overview.add_child(l)
		return l

	overview_lbl_name = make_lbl.call(Vector2(20, 10), Vector2(310, 30))
	overview_lbl_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	
	overview_lbl_users = make_lbl.call(Vector2(340, 10), Vector2(140, 30))
	overview_lbl_age = make_lbl.call(Vector2(490, 10), Vector2(140, 30))

func _refresh_overview() -> void:
	var d := GameManager.my_distro
	if d == null:
		return
	overview_lbl_name.text = "Name: %s %d.0" % [d.name, d.released_ver]
	overview_lbl_users.text = "Users: %d" % d.users
	overview_lbl_age.text = "Age: %d days" % d.get_distro_age_in_days()

func _build_con_distro_rank() -> void:
	con_distro_rank = DraggableWindow.new()
	# Widened to 220px; height 401px aligns bottom with con_distro_stats (68 + 401 = 469)
	con_distro_rank.size = Vector2(220, 401)
	can_main.add_child(con_distro_rank)

	_add_label(con_distro_rank, "DistroRank", Vector2(12, 11), Vector2(196, 20), 11, HORIZONTAL_ALIGNMENT_CENTER)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(12, 33)
	bg.size = Vector2(196, 354)
	con_distro_rank.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(12, 33)
	scroll.size = Vector2(196, 354)
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
		row.custom_minimum_size = Vector2(182, 34)
		row.color = Color8(230, 240, 255) if d == GameManager.my_distro else (Color.WHITE if i % 2 == 0 else Color8(245, 245, 245))

		var l_num := _add_label(row, str(i + 1), Vector2(3, 7), Vector2(24, 20), 13)
		l_num.add_theme_color_override("font_color", Color.BLACK)

		var l_name := _add_label(row, d.name, Vector2(28, 2), Vector2(150, 16), 11)
		l_name.add_theme_color_override("font_color", Color.BLACK)

		var l_users := _add_label(row, "Users: %d" % d.users, Vector2(28, 17), Vector2(150, 14), 9)
		l_users.add_theme_color_override("font_color", Color8(60, 60, 60))

		rank_vbox.add_child(row)

func _build_con_notifications() -> void:
	con_notifications = DraggableWindow.new()
	# Narrowed to 420px to leave a 10px gap before DistroRank; height 401px aligns bottom with Distro Stats
	con_notifications.size = Vector2(420, 401)
	can_main.add_child(con_notifications)

	var bryan := TextureRect.new()
	bryan.texture = tex_bryan
	bryan.position = Vector2(14, 17)
	bryan.size = Vector2(46, 99)
	bryan.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_notifications.add_child(bryan)

	notif_lbl = RichTextLabel.new()
	notif_lbl.position = Vector2(68, 17)
	notif_lbl.size = Vector2(338, 370)
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
	con_package_selection.size = Vector2(600, 460)
	can_main.add_child(con_package_selection)

	_add_label(con_package_selection, "Package Selection", Vector2(15, 12), Vector2(200, 20), 13)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 40)
	bg.size = Vector2(570, 360)
	con_package_selection.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(15, 40)
	scroll.size = Vector2(570, 360) 
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_package_selection.add_child(scroll)

	pkg_vbox = VBoxContainer.new()
	pkg_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	pkg_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(pkg_vbox)

	var opt_sort := OptionButton.new()
	opt_sort.position = Vector2(270, 415)
	opt_sort.size = Vector2(230, 30)
	opt_sort.add_item("Sort: Default")
	opt_sort.add_item("Sort: Alphabetical")
	opt_sort.add_item("Sort: Bug Count")
	opt_sort.add_item("Sort: Nerd Cred")
	opt_sort.add_item("Sort: Open Source")
	opt_sort.add_item("Sort: Popularity")
	opt_sort.add_item("Sort: Size")
	opt_sort.add_theme_color_override("font_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_hover_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_pressed_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_focus_color", Color.WHITE)
	
	var popup := opt_sort.get_popup()
	popup.add_theme_color_override("font_color", Color.WHITE)
	popup.add_theme_color_override("font_hover_color", Color.WHITE)

	opt_sort.selected = pkg_sort_mode
	opt_sort.item_selected.connect(func(idx: int):
		pkg_sort_mode = idx
		_refresh_package_selection()
	)
	con_package_selection.add_child(opt_sort)

	var btn_ok := _add_button(con_package_selection, "OK!", Vector2(510, 415), Vector2(75, 30))
	btn_ok.pressed.connect(_on_package_selection_ok)

func _refresh_package_selection() -> void:
	for child in pkg_vbox.get_children():
		child.queue_free()

	var d := GameManager.my_distro
	
	var sorted_indices: Array[int] = []
	for i in range(GameManager.packages_available.size()):
		sorted_indices.append(i)

	if pkg_sort_mode == 1: # Alphabetical
		sorted_indices.sort_custom(func(a: int, b: int) -> bool: 
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)
	elif pkg_sort_mode == 2: # Bug Count
		sorted_indices.sort_custom(func(a: int, b: int) -> bool: 
			var val_a = GameManager.packages_available[a].bugs
			var val_b = GameManager.packages_available[b].bugs
			if val_a != val_b: return val_a > val_b
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)
	elif pkg_sort_mode == 3: # Nerd Cred
		sorted_indices.sort_custom(func(a: int, b: int) -> bool: 
			var val_a = GameManager.packages_available[a].nerd_cred
			var val_b = GameManager.packages_available[b].nerd_cred
			if val_a != val_b: return val_a > val_b
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)
	elif pkg_sort_mode == 4: # Open Source (True > False)
		sorted_indices.sort_custom(func(a: int, b: int) -> bool: 
			var val_a = GameManager.packages_available[a].is_open_source
			var val_b = GameManager.packages_available[b].is_open_source
			if val_a != val_b: return val_a
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)
	elif pkg_sort_mode == 5: # Popularity
		sorted_indices.sort_custom(func(a: int, b: int) -> bool:
			var val_a = GameManager.packages_available[a].popularity
			var val_b = GameManager.packages_available[b].popularity
			if val_a != val_b: return val_a > val_b
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)
	elif pkg_sort_mode == 6: # Size
		sorted_indices.sort_custom(func(a: int, b: int) -> bool:
			var val_a = GameManager.packages_available[a].size_in_mb
			var val_b = GameManager.packages_available[b].size_in_mb
			if val_a != val_b: return val_a > val_b
			return GameManager.packages_available[a].name < GameManager.packages_available[b].name
		)

	var row_index := 0
	for pkg_idx in sorted_indices:
		var p := GameManager.packages_available[pkg_idx]
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(550, 60)
		row.color = Color.WHITE if row_index % 2 == 0 else Color8(242, 242, 242)

		var chk := CheckBox.new()
		chk.position = Vector2(10, 16)
		chk.size = Vector2(24, 24) 
		chk.button_pressed = d.is_package_in_distro(pkg_idx)
		
		var capture_idx := pkg_idx
		chk.toggled.connect(func(pressed: bool):
			if pressed:
				d.add_package_to_distro(capture_idx)
			else:
				d.remove_package_from_distro(capture_idx)
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
		row_index += 1

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
	con_worker_assignment.size = Vector2(550, 380)
	can_main.add_child(con_worker_assignment)

	_add_label(con_worker_assignment, "Worker Assignment", Vector2(15, 12), Vector2(200, 20), 13)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 36)
	bg.size = Vector2(200, 324) # Fits 9 rows of 36px cleanly with a 20px bottom margin
	con_worker_assignment.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(15, 36)
	scroll.size = Vector2(200, 324)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_worker_assignment.add_child(scroll)

	work_list_vbox = VBoxContainer.new()
	work_list_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	work_list_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(work_list_vbox)

	# Availability counts (Right edge aligned at X = 505)
	_add_label(con_worker_assignment, "Available Paid Workers :", Vector2(230, 38), Vector2(180, 20), 11)
	work_lbl_avail_paid = _add_label(con_worker_assignment, "0 / 0", Vector2(425, 38), Vector2(80, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	_add_label(con_worker_assignment, "Available Volunteers :", Vector2(230, 70), Vector2(180, 20), 11)
	work_lbl_avail_vol = _add_label(con_worker_assignment, "0 / 0", Vector2(425, 70), Vector2(80, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)

	work_lbl_pkg_name = _add_label(con_worker_assignment, "", Vector2(230, 125), Vector2(275, 22), 13)

	var setup_icon_btn = func(b: Button, tex: Texture2D, pos: Vector2):
		b.position = pos
		b.size = Vector2(22, 22)
		b.icon = tex
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		var sb := StyleBoxFlat.new()
		sb.bg_color = Color8(89, 131, 192)
		sb.border_color = Color8(60, 107, 173)
		sb.set_border_width_all(1)
		b.add_theme_stylebox_override("normal", sb)
		
		var sb_h := sb.duplicate()
		sb_h.bg_color = Color8(47, 92, 159)
		b.add_theme_stylebox_override("hover", sb_h)
		
		var sb_p := sb.duplicate()
		sb_p.bg_color = Color8(35, 75, 140)
		b.add_theme_stylebox_override("pressed", sb_p)
		
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		con_worker_assignment.add_child(b)

	# Indented left so the '+' button right edge (483 + 22 = 505) matches the availability counts
	_add_label(con_worker_assignment, "Paid Workers", Vector2(242, 162), Vector2(130, 20), 11)
	work_lbl_assign_paid = _add_label(con_worker_assignment, "0", Vector2(390, 162), Vector2(50, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)
	
	var btn_p_minus := Button.new()
	setup_icon_btn.call(btn_p_minus, tex_remove, Vector2(455, 161))
	_set_desktop_tooltip(btn_p_minus, "Remove Paid Worker")
	
	var btn_p_plus := Button.new()
	setup_icon_btn.call(btn_p_plus, tex_add, Vector2(483, 161))
	_set_desktop_tooltip(btn_p_plus, "Assign Paid Worker")
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

	_add_label(con_worker_assignment, "Volunteers", Vector2(242, 194), Vector2(130, 20), 11)
	work_lbl_assign_vol = _add_label(con_worker_assignment, "0", Vector2(390, 194), Vector2(50, 20), 11, HORIZONTAL_ALIGNMENT_RIGHT)
	
	var btn_v_minus := Button.new()
	setup_icon_btn.call(btn_v_minus, tex_remove, Vector2(455, 193))
	_set_desktop_tooltip(btn_v_minus, "Remove Volunteer")
	
	var btn_v_plus := Button.new()
	setup_icon_btn.call(btn_v_plus, tex_add, Vector2(483, 193))
	_set_desktop_tooltip(btn_v_plus, "Assign Volunteer")

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

	# Sacrifice Worker positioned above the Sort dropdown
	var btn_sac := _add_button(con_worker_assignment, "Sacrifice Worker", Vector2(230, 290), Vector2(220, 30))
	btn_sac.pressed.connect(func():
		con_worker_assignment.visible = false
		center_container(con_sacrifice_worker)
		_refresh_sacrifice_worker()
		con_sacrifice_worker.visible = true
	)

	# Upward-opening Sort dropdown next to OK! (20px above the bottom border)
	var opt_sort := OptionButton.new()
	opt_sort.position = Vector2(230, 330)
	opt_sort.size = Vector2(220, 30)
	opt_sort.add_item("Sort: Default")
	opt_sort.add_item("Sort: Alphabetical")
	opt_sort.add_item("Sort: Bug Count")
	opt_sort.add_item("Sort: Paid Workers Assigned")
	opt_sort.add_item("Sort: Volunteers Assigned")
	opt_sort.add_theme_color_override("font_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_hover_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_pressed_color", Color.WHITE)
	opt_sort.add_theme_color_override("font_focus_color", Color.WHITE)

	var popup := opt_sort.get_popup()
	popup.add_theme_color_override("font_color", Color.WHITE)
	popup.add_theme_color_override("font_hover_color", Color.WHITE)
	popup.about_to_popup.connect(func():
		var place_upward = func():
			var screen_pos := opt_sort.get_screen_position()
			popup.position = Vector2i(int(screen_pos.x), int(screen_pos.y) - popup.size.y)
		place_upward.call_deferred()
	)

	opt_sort.selected = work_sort_mode
	opt_sort.item_selected.connect(func(idx: int):
		work_sort_mode = idx
		_refresh_worker_assignment()
	)
	con_worker_assignment.add_child(opt_sort)

	var btn_ok := _add_button(con_worker_assignment, "OK!", Vector2(460, 330), Vector2(75, 30))
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

	var sorted_inc_indices: Array[int] = []
	for i in range(d.packages_included.size()):
		sorted_inc_indices.append(i)

	if work_sort_mode == 1: # Alphabetical
		sorted_inc_indices.sort_custom(func(a: int, b: int) -> bool:
			var pkg_a := GameManager.packages_available[d.packages_included[a]]
			var pkg_b := GameManager.packages_available[d.packages_included[b]]
			return pkg_a.name < pkg_b.name
		)
	elif work_sort_mode == 2: # Bug Count
		sorted_inc_indices.sort_custom(func(a: int, b: int) -> bool:
			var pkg_a := GameManager.packages_available[d.packages_included[a]]
			var pkg_b := GameManager.packages_available[d.packages_included[b]]
			if pkg_a.bugs != pkg_b.bugs: return pkg_a.bugs > pkg_b.bugs
			return pkg_a.name < pkg_b.name
		)
	elif work_sort_mode == 3: # Paid Workers Assigned
		sorted_inc_indices.sort_custom(func(a: int, b: int) -> bool:
			var paid_a := d.workers_paid_assigned[a]
			var paid_b := d.workers_paid_assigned[b]
			if paid_a != paid_b: return paid_a > paid_b
			var pkg_a := GameManager.packages_available[d.packages_included[a]]
			var pkg_b := GameManager.packages_available[d.packages_included[b]]
			return pkg_a.name < pkg_b.name
		)
	elif work_sort_mode == 4: # Volunteers Assigned
		sorted_inc_indices.sort_custom(func(a: int, b: int) -> bool:
			var vol_a := d.workers_volunteers_assigned[a]
			var vol_b := d.workers_volunteers_assigned[b]
			if vol_a != vol_b: return vol_a > vol_b
			var pkg_a := GameManager.packages_available[d.packages_included[a]]
			var pkg_b := GameManager.packages_available[d.packages_included[b]]
			return pkg_a.name < pkg_b.name
		)

	var row_index := 0
	for inc_idx in sorted_inc_indices:
		var pkg_idx := d.packages_included[inc_idx]
		var p := GameManager.packages_available[pkg_idx]

		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(186, 36)
		row.color = Color8(205, 225, 255) if inc_idx == work_selected_idx else (Color.WHITE if row_index % 2 == 0 else Color8(242, 242, 242))

		var l_title := _add_label(row, "%s %d.0" % [p.name, p.version], Vector2(4, 2), Vector2(178, 16), 11)
		l_title.add_theme_color_override("font_color", Color.BLACK)

		var sub := "Bugs: %d  Vol: %d  Paid: %d" % [p.bugs, d.workers_volunteers_assigned[inc_idx], d.workers_paid_assigned[inc_idx]]
		var l_sub := _add_label(row, sub, Vector2(4, 18), Vector2(178, 14), 9)
		l_sub.add_theme_color_override("font_color", Color8(70, 70, 70))

		var click_btn := Button.new()
		click_btn.flat = true
		click_btn.set_anchors_preset(Control.PRESET_FULL_RECT)
		var idx_capture := inc_idx
		click_btn.pressed.connect(func():
			work_selected_idx = idx_capture
			_refresh_worker_assignment()
		)
		row.add_child(click_btn)
		work_list_vbox.add_child(row)
		row_index += 1

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

	var btn_ok := _add_button(con_sacrifice_worker, "No more!", Vector2(85, 166), Vector2(162, 30))
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
	con_new_release.size = Vector2(410, 190)
	can_main.add_child(con_new_release)

	bryan_new_release = TextureRect.new()
	bryan_new_release.texture = tex_bryan
	bryan_new_release.position = Vector2(14, 17)
	bryan_new_release.size = Vector2(46, 99)
	bryan_new_release.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	con_new_release.add_child(bryan_new_release)

	release_lbl_text = _add_label(con_new_release, "", Vector2(72, 17), Vector2(314, 99), 11)
	release_lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	btn_ok_new_release = _add_button(con_new_release, "OK!", Vector2(315, 145), Vector2(80, 30))
	btn_ok_new_release.pressed.connect(_on_new_release_ok_clicked)

func _build_con_settings() -> void:
	con_settings = DraggableWindow.new()
	con_settings.size = Vector2(340, 320) 
	can_main.add_child(con_settings)

	_add_label(con_settings, "Settings", Vector2(15, 12), Vector2(200, 20), 16)

	var lbl_lang := _add_label(con_settings, "Language:", Vector2(25, 45), Vector2(100, 20), 13)
	lbl_lang.add_theme_color_override("font_color", Color.WHITE)

	var opt_lang := OptionButton.new()
	opt_lang.position = Vector2(125, 40)
	opt_lang.size = Vector2(180, 25)
	opt_lang.add_item("English")
	opt_lang.add_theme_color_override("font_color", Color.WHITE)
	opt_lang.add_theme_color_override("font_hover_color", Color.WHITE)
	opt_lang.add_theme_color_override("font_pressed_color", Color.WHITE)
	con_settings.add_child(opt_lang)

	var lbl_vol := _add_label(con_settings, "Music Volume:", Vector2(25, 85), Vector2(100, 20), 13)
	lbl_vol.add_theme_color_override("font_color", Color.WHITE)

	var sld_vol := HSlider.new()
	sld_vol.position = Vector2(125, 85)
	sld_vol.size = Vector2(180, 20)
	sld_vol.min_value = 0
	sld_vol.max_value = 100
	sld_vol.value = music_volume
	sld_vol.value_changed.connect(func(val: float):
		music_volume = val
		if is_muted and val > 0:
			_on_mute_toggled() 
		_update_volume()
	)
	con_settings.add_child(sld_vol)

	chk_mute = CheckBox.new()
	chk_mute.text = "Mute Music"
	chk_mute.position = Vector2(120, 120) 
	chk_mute.size = Vector2(150, 24)
	chk_mute.add_theme_color_override("font_color", Color.WHITE)
	chk_mute.add_theme_color_override("font_hover_color", Color.WHITE)
	chk_mute.add_theme_color_override("font_pressed_color", Color.WHITE)
	chk_mute.add_theme_font_size_override("font_size", 13)
	chk_mute.button_pressed = is_muted
	chk_mute.toggled.connect(func(pressed: bool):
		is_muted = pressed
		btn_mute.icon = tex_mute if is_muted else tex_volume_up
		_update_volume()
	)
	con_settings.add_child(chk_mute)
	
	var lbl_sys := _add_label(con_settings, "System Time:", Vector2(25, 160), Vector2(100, 20), 13)
	lbl_sys.add_theme_color_override("font_color", Color.WHITE)

	var opt_sys := OptionButton.new()
	opt_sys.position = Vector2(125, 155)
	opt_sys.size = Vector2(180, 25)
	opt_sys.add_item("None")
	opt_sys.add_item("12-Hour (AM/PM)")
	opt_sys.add_item("12-Hour (with seconds)")
	opt_sys.add_item("24-Hour (HH:MM)")
	opt_sys.add_item("24-Hour (with seconds)")
	opt_sys.add_theme_color_override("font_color", Color.WHITE)
	opt_sys.add_theme_color_override("font_hover_color", Color.WHITE)
	opt_sys.add_theme_color_override("font_pressed_color", Color.WHITE)
	opt_sys.selected = sys_time_format
	opt_sys.item_selected.connect(func(idx: int):
		sys_time_format = idx
		_update_system_time()
	)
	con_settings.add_child(opt_sys)

	var chk_fullscreen := CheckBox.new()
	chk_fullscreen.text = "Fullscreen"
	chk_fullscreen.position = Vector2(120, 195) 
	chk_fullscreen.size = Vector2(150, 24)
	chk_fullscreen.add_theme_color_override("font_color", Color.WHITE)
	chk_fullscreen.add_theme_color_override("font_hover_color", Color.WHITE)
	chk_fullscreen.add_theme_color_override("font_pressed_color", Color.WHITE)
	chk_fullscreen.add_theme_font_size_override("font_size", 13)
	chk_fullscreen.button_pressed = (DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN or DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	chk_fullscreen.toggled.connect(func(pressed: bool):
		if pressed:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	)
	con_settings.add_child(chk_fullscreen)

	var chk_hide_mp3 := CheckBox.new()
	chk_hide_mp3.text = "Hide MP3 Player"
	chk_hide_mp3.position = Vector2(120, 230) 
	chk_hide_mp3.size = Vector2(150, 24)
	chk_hide_mp3.add_theme_color_override("font_color", Color.WHITE)
	chk_hide_mp3.add_theme_color_override("font_hover_color", Color.WHITE)
	chk_hide_mp3.add_theme_color_override("font_pressed_color", Color.WHITE)
	chk_hide_mp3.add_theme_font_size_override("font_size", 13)
	chk_hide_mp3.button_pressed = !show_mp3_player
	chk_hide_mp3.toggled.connect(func(pressed: bool):
		show_mp3_player = !pressed
		_update_mp3_visibility()
	)
	con_settings.add_child(chk_hide_mp3)

	var btn_ok := _add_button(con_settings, "OK!", Vector2(250, 275), Vector2(75, 30))
	btn_ok.pressed.connect(func(): con_settings.visible = false)

func _build_con_confirm_release() -> void:
	con_confirm_release = DraggableWindow.new()
	con_confirm_release.size = Vector2(400, 180)
	con_confirm_release.z_index = 100
	can_main.add_child(con_confirm_release)

	_add_label(con_confirm_release, "Release Version", Vector2(15, 12), Vector2(370, 20), 13)

	var lbl_text := _add_label(con_confirm_release, "Are you ready to release this version?\nYou won't be able to change any packages or fix any bugs\nin this version once it is released.", Vector2(0, 45), Vector2(400, 56), 11, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_text.add_theme_color_override("font_color", Color.WHITE) 
	lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var btn_yes := _add_button(con_confirm_release, "Yes", Vector2(115, 130), Vector2(80, 30))
	btn_yes.pressed.connect(func():
		con_confirm_release.visible = false
		_on_release_version_confirmed()
	)

	var btn_no := _add_button(con_confirm_release, "No", Vector2(205, 130), Vector2(80, 30))
	btn_no.pressed.connect(func():
		con_confirm_release.visible = false
		unpause_game()
	)

func _build_con_confirm_save() -> void:
	con_confirm_save = DraggableWindow.new()
	con_confirm_save.size = Vector2(340, 180)
	con_confirm_release.z_index = 100
	can_main.add_child(con_confirm_save)

	_add_label(con_confirm_save, "Overwrite Save?", Vector2(15, 12), Vector2(310, 20), 13)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 35)
	bg.size = Vector2(310, 80)
	con_confirm_save.add_child(bg)

	var lbl_text := _add_label(con_confirm_save, "Are you sure you want to overwrite your\ncurrently loaded save file?", Vector2(0, 48), Vector2(340, 56), 11, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_text.add_theme_color_override("font_color", Color.BLACK)
	lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var btn_yes := _add_button(con_confirm_save, "Yes", Vector2(85, 130), Vector2(80, 30))
	btn_yes.pressed.connect(func():
		con_confirm_save.visible = false
		var f := FileAccess.open(current_save_path, FileAccess.WRITE)
		if f:
			f.store_string(GameManager.generate_save_xml())
			f.close()
			GameManager.show_message("Game successfully overwritten!")
		unpause_game()
	)

	var btn_no := _add_button(con_confirm_save, "No", Vector2(175, 130), Vector2(80, 30))
	btn_no.pressed.connect(func():
		con_confirm_save.visible = false
		unpause_game()
	)

func _build_con_confirm_quit() -> void:
	con_confirm_quit = DraggableWindow.new()
	con_confirm_quit.size = Vector2(340, 180)
	con_confirm_release.z_index = 100
	can_main.add_child(con_confirm_quit)

	_add_label(con_confirm_quit, "Quit Game", Vector2(15, 12), Vector2(310, 20), 13)

	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 35)
	bg.size = Vector2(310, 80)
	con_confirm_quit.add_child(bg)

	var lbl_text := _add_label(con_confirm_quit, "Do you want to quit to the main menu?\nUnsaved progress will be lost.", Vector2(0, 48), Vector2(340, 56), 11, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_text.add_theme_color_override("font_color", Color.BLACK)
	lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var btn_ok := _add_button(con_confirm_quit, "OK!", Vector2(85, 130), Vector2(80, 30))
	btn_ok.pressed.connect(func():
		con_confirm_quit.visible = false
		_hide_all_containers()
		GameManager.my_distro = null
		
		btn_save_as_top.visible = false 
		lbl_date.visible = false 
		btn_pause.visible = false 
		lbl_paused.visible = false 
		GameManager.is_paused = false 
		
		center_container(con_main_menu)
		con_main_menu.visible = true
		lbl_date.text = ""
	)

	var btn_cancel := _add_button(con_confirm_quit, "Cancel", Vector2(175, 130), Vector2(80, 30))
	btn_cancel.pressed.connect(func():
		con_confirm_quit.visible = false
		unpause_game()
	)

func _build_con_confirm_desktop() -> void:
	con_confirm_desktop = DraggableWindow.new()
	con_confirm_desktop.size = Vector2(340, 180)
	con_confirm_release.z_index = 100
	can_main.add_child(con_confirm_desktop)

	_add_label(con_confirm_desktop, "Quit Linux Tycoon", Vector2(15, 12), Vector2(310, 20), 13)

	var lbl_text := _add_label(con_confirm_desktop, "Are you sure you want to quit Linux Tycoon?", Vector2(0, 50), Vector2(340, 56), 11, HORIZONTAL_ALIGNMENT_CENTER)
	lbl_text.add_theme_color_override("font_color", Color.WHITE)
	lbl_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

	var btn_ok := _add_button(con_confirm_desktop, "OK!", Vector2(85, 130), Vector2(80, 30))
	btn_ok.pressed.connect(func():
		get_tree().quit()
	)

	var btn_cancel := _add_button(con_confirm_desktop, "Cancel", Vector2(175, 130), Vector2(80, 30))
	btn_cancel.pressed.connect(func():
		con_confirm_desktop.visible = false
	)

func _build_con_credits() -> void:
	con_credits = DraggableWindow.new()
	con_credits.size = Vector2(400, 210)
	can_main.add_child(con_credits)

	_add_label(con_credits, "Credits", Vector2(15, 12), Vector2(200, 20), 16)

	var lbl_dev := _add_label(con_credits, "Originally developed by Bryan Lunduke", Vector2(20, 45), Vector2(360, 20), 13)
	lbl_dev.add_theme_color_override("font_color", Color.WHITE)

	var lbl_port := _add_label(con_credits, "Ported to the Redot Engine by Hal Motley (inferno986return)", Vector2(20, 75), Vector2(360, 20), 13)
	lbl_port.add_theme_color_override("font_color", Color.WHITE)

	var lbl_icons := _add_label(con_credits, "UI Icons by Google Material Icons (Apache License 2.0):", Vector2(20, 105), Vector2(360, 20), 13)
	lbl_icons.add_theme_color_override("font_color", Color.WHITE)

	var link_icons := LinkButton.new()
	link_icons.text = "https://www.apache.org/licenses/LICENSE-2.0"
	link_icons.position = Vector2(20, 125)
	link_icons.add_theme_font_size_override("font_size", 11)
	link_icons.add_theme_color_override("font_color", Color.WHITE)
	link_icons.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_icons.uri = "https://www.apache.org/licenses/LICENSE-2.0"
	con_credits.add_child(link_icons)

	var btn_music := _add_button(con_credits, "Music", Vector2(140, 165), Vector2(75, 30))
	btn_music.pressed.connect(func():
		con_credits.visible = false
		center_container(con_music)
		con_music.visible = true
	)

	var btn_license := _add_button(con_credits, "License", Vector2(225, 165), Vector2(75, 30))
	btn_license.pressed.connect(func():
		con_credits.visible = false
		center_container(con_license)
		con_license.visible = true
	)

	var btn_ok := _add_button(con_credits, "OK!", Vector2(310, 165), Vector2(75, 30))
	btn_ok.pressed.connect(func(): con_credits.visible = false)

func _build_con_music() -> void:
	con_music = DraggableWindow.new()
	con_music.size = Vector2(400, 372) # Increased by 22px for Track 10
	can_main.add_child(con_music)

	_add_label(con_music, "Music Credits", Vector2(15, 12), Vector2(200, 20), 16)

	var lbl_music := _add_label(con_music, "Music provided by Pixabay:", Vector2(20, 45), Vector2(360, 20), 13)
	lbl_music.add_theme_color_override("font_color", Color.WHITE)

	var link_pixabay := LinkButton.new()
	link_pixabay.text = "https://pixabay.com/service/license-summary/"
	link_pixabay.position = Vector2(20, 65)
	link_pixabay.add_theme_font_size_override("font_size", 11)
	link_pixabay.add_theme_color_override("font_color", Color.WHITE)
	link_pixabay.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_pixabay.uri = "https://pixabay.com/service/license-summary/"
	con_music.add_child(link_pixabay)

	var tracks = [
		"Alex Morgan — Downtempo Chill Electronic",
		"Amplify Music — Jazz Cafe Music",
		"Kulakovka — Inspiring Downtempo",
		"Soundsurfer — Downtempo",
		"Turning Pages — Kindling The Flame",
		"Alex Morgan — Acid Jazz Cafe",
		"Tunetank — Inspiring Downtempo",
		"Pavetraxx — Digital Beauty",
		"Serge Pavkin — Looking at the Horizon",
		"Tunetank — Downtempo Beat"
	]
	
	for i in range(tracks.size()):
		var y_pos = 95 + (i * 22)
		var lbl_t := _add_label(con_music, "• " + tracks[i], Vector2(20, y_pos), Vector2(360, 20), 11)
		lbl_t.add_theme_color_override("font_color", Color.WHITE)

	var btn_ok := _add_button(con_music, "OK!", Vector2(310, 327), Vector2(75, 30))
	btn_ok.pressed.connect(func():
		con_music.visible = false
		con_credits.visible = true
	)

func _build_con_mp3_player() -> void:
	con_mp3_player = DraggableWindow.new()
	con_mp3_player.size = Vector2(400, 440) # Height increased to 440px
	can_main.add_child(con_mp3_player)

	_add_label(con_mp3_player, "MP3 Player", Vector2(15, 12), Vector2(200, 20), 16)

	# --- Control Buttons (Centered at Y=45) ---
	var sb_icon_btn := StyleBoxFlat.new()
	sb_icon_btn.bg_color = Color8(89, 131, 192)
	sb_icon_btn.border_color = Color8(60, 107, 173)
	sb_icon_btn.set_border_width_all(1)
	
	var sb_icon_hover := sb_icon_btn.duplicate()
	sb_icon_hover.bg_color = Color8(47, 92, 159)
	
	var sb_icon_pressed := sb_icon_btn.duplicate()
	sb_icon_pressed.bg_color = Color8(35, 75, 140)

	var build_ctrl_btn = func(tex: Texture2D, pos: Vector2) -> Button:
		var b := Button.new()
		b.position = pos
		b.size = Vector2(30, 30)
		b.icon = tex
		b.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
		b.add_theme_stylebox_override("normal", sb_icon_btn)
		b.add_theme_stylebox_override("hover", sb_icon_hover)
		b.add_theme_stylebox_override("pressed", sb_icon_pressed)
		b.add_theme_stylebox_override("disabled", sb_icon_btn)
		b.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
		con_mp3_player.add_child(b)
		return b

	btn_mp3_play = build_ctrl_btn.call(tex_play, Vector2(85, 45)) as Button
	_set_desktop_tooltip(btn_mp3_play, "Play")
	btn_mp3_pause = build_ctrl_btn.call(tex_pause, Vector2(125, 45)) as Button
	_set_desktop_tooltip(btn_mp3_pause, "Pause")
	btn_mp3_stop = build_ctrl_btn.call(tex_stop, Vector2(165, 45)) as Button
	_set_desktop_tooltip(btn_mp3_stop, "Stop")
	var btn_prev: Button = build_ctrl_btn.call(tex_skip_prev, Vector2(205, 45)) as Button
	_set_desktop_tooltip(btn_prev, "Previous Track")
	var btn_next: Button = build_ctrl_btn.call(tex_skip_next, Vector2(245, 45)) as Button
	_set_desktop_tooltip(btn_next, "Next Track")
	btn_mp3_shuf = build_ctrl_btn.call(tex_shuffle, Vector2(285, 45)) as Button
	_set_desktop_tooltip(btn_mp3_shuf, "Toggle Shuffle")

	btn_mp3_play.pressed.connect(func():
		is_mp3_playing = true
		is_mp3_paused = false
		audio_player.stream_paused = false
		if not audio_player.playing:
			audio_player.play()
		_sync_mp3_ui()
	)

	btn_mp3_pause.pressed.connect(func():
		if is_mp3_playing:
			is_mp3_paused = true
			audio_player.stream_paused = true
			_sync_mp3_ui()
	)

	btn_mp3_stop.pressed.connect(func():
		is_mp3_playing = false
		is_mp3_paused = false
		audio_player.stream_paused = false
		audio_player.stop()
		_sync_mp3_ui()
	)
	
	btn_prev.pressed.connect(func(): _play_track(current_track_idx - 1))
	btn_next.pressed.connect(func(): _play_track(current_track_idx + 1))
	
	btn_mp3_shuf.pressed.connect(func():
		is_shuffled = not is_shuffled
		if is_shuffled:
			playlist.shuffle()
			_play_track(0)
			_refresh_mp3_list() # FIXED: Refreshes list instead of building a new window
		else:
			_sync_mp3_ui()
	)

	# --- Track List Background ---
	var bg := ColorRect.new()
	bg.color = Color.WHITE
	bg.position = Vector2(15, 85)
	bg.size = Vector2(370, 300) # Increased height to 300px
	con_mp3_player.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(15, 85)
	scroll.size = Vector2(370, 300)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	con_mp3_player.add_child(scroll)

	playlist_vbox = VBoxContainer.new()
	playlist_vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	playlist_vbox.add_theme_constant_override("separation", 0)
	scroll.add_child(playlist_vbox)

	_refresh_mp3_list()
	_sync_mp3_ui()

	# --- Bottom Row Buttons (Y = 395) ---
	var btn_enable_all := _add_button(con_mp3_player, "Enable All", Vector2(15, 395), Vector2(90, 30))
	btn_enable_all.pressed.connect(func():
		for t in playlist:
			t["enabled"] = true
		_refresh_mp3_list()
	)

	var btn_disable_all := _add_button(con_mp3_player, "Disable All", Vector2(115, 395), Vector2(90, 30))
	btn_disable_all.pressed.connect(func():
		for t in playlist:
			t["enabled"] = false
		_refresh_mp3_list()
	)

	var btn_ok := _add_button(con_mp3_player, "OK!", Vector2(310, 395), Vector2(75, 30))
	btn_ok.pressed.connect(func(): con_mp3_player.visible = false)

func _refresh_mp3_list() -> void:
	if playlist_vbox == null:
		return
	for child in playlist_vbox.get_children():
		child.queue_free()

	for i in range(playlist.size()):
		var track = playlist[i]
		var is_selected := (i == current_track_idx)
		var row := ColorRect.new()
		row.custom_minimum_size = Vector2(360, 30)
		if is_selected:
			row.color = Color8(89, 131, 192)
		else:
			row.color = Color.WHITE if i % 2 == 0 else Color8(242, 242, 242)

		# Invisible button sits in background without stealing focus box
		var btn_play_direct := Button.new()
		btn_play_direct.flat = true
		btn_play_direct.focus_mode = Control.FOCUS_NONE
		btn_play_direct.set_anchors_preset(Control.PRESET_FULL_RECT)
		var cap_idx := i
		btn_play_direct.pressed.connect(func():
			is_mp3_playing = true
			is_mp3_paused = false
			_play_track(cap_idx)
			_sync_mp3_ui()
		)
		row.add_child(btn_play_direct)

		# Checkbox sits on top
		var chk := CheckBox.new()
		chk.position = Vector2(10, 3)
		chk.size = Vector2(24, 24) 
		chk.button_pressed = track["enabled"]
		chk.toggled.connect(func(pressed: bool):
			playlist[cap_idx]["enabled"] = pressed
		)
		row.add_child(chk)

		var display_title = "%d. %s" % [i + 1, track["title"]]
		var l_title := _add_label(row, display_title, Vector2(45, 0), Vector2(300, 30), 11)
		l_title.add_theme_color_override("font_color", Color.WHITE if is_selected else Color.BLACK)
		
		playlist_vbox.add_child(row)

func _build_con_license() -> void:
	con_license = DraggableWindow.new()
	con_license.size = Vector2(550, 460)
	can_main.add_child(con_license)

	_add_label(con_license, "License", Vector2(15, 12), Vector2(200, 20), 16)

	var lbl_intro := _add_label(con_license, "Linux Tycoon is licensed under GNU General Public License v2 (GPLv2):", Vector2(15, 40), Vector2(520, 20), 13)
	lbl_intro.add_theme_color_override("font_color", Color.WHITE)

	var link_lic := LinkButton.new()
	link_lic.text = "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
	link_lic.position = Vector2(15, 62)
	link_lic.add_theme_font_size_override("font_size", 13)
	link_lic.add_theme_color_override("font_color", Color.WHITE)
	link_lic.add_theme_color_override("font_hover_color", Color8(200, 200, 255))
	link_lic.uri = "https://www.gnu.org/licenses/old-licenses/gpl-2.0.en.html"
	con_license.add_child(link_lic)

	var bg := ColorRect.new()
	# --- FIXED: Background is now the standard blue, not white ---
	bg.color = Color8(89, 131, 192)
	# -------------------------------------------------------------
	bg.position = Vector2(15, 90)
	bg.size = Vector2(520, 315)
	con_license.add_child(bg)

	var scroll := ScrollContainer.new()
	scroll.position = Vector2(20, 95)
	scroll.size = Vector2(510, 305)
	# --- FIXED: Horizontal scrolling is disabled so the text wraps properly ---
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	# --------------------------------------------------------------------------
	con_license.add_child(scroll)

	var lbl_lic := Label.new()
	lbl_lic.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	lbl_lic.custom_minimum_size = Vector2(490, 0)
	# --- FIXED: Font color changed to white ---
	lbl_lic.add_theme_color_override("font_color", Color.WHITE)
	# ------------------------------------------
	lbl_lic.add_theme_font_size_override("font_size", 11)
	
	lbl_lic.text = """GNU GENERAL PUBLIC LICENSE
Version 2, June 1991

Copyright (C) 1989, 1991 Free Software Foundation, Inc.,
51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA
Everyone is permitted to copy and distribute verbatim copies
of this license document, but changing it is not allowed.

Preamble

The licenses for most software are designed to take away your
freedom to share and change it.  By contrast, the GNU General Public
License is intended to guarantee your freedom to share and change free
software--to make sure the software is free for all its users.  This
General Public License applies to most of the Free Software
Foundation's software and to any other program whose authors commit to
using it.  (Some other Free Software Foundation software is covered by
the GNU Lesser General Public License instead.)  You can apply it to
your programs, too.

When we speak of free software, we are referring to freedom, not
price.  Our General Public Licenses are designed to make sure that you
have the freedom to distribute copies of free software (and charge for
this service if you wish), that you receive source code or can get it
if you want it, that you can change the software or use pieces of it
in new free programs; and that you know you can do these things.

To protect your rights, we need to make restrictions that forbid
anyone to deny you these rights or to ask you to surrender the rights.
These restrictions translate to certain responsibilities for you if you
distribute copies of the software, or if you modify it.

For example, if you distribute copies of such a program, whether
gratis or for a fee, you must give the recipients all the rights that
you have.  You must make sure that they, too, receive or can get the
source code.  And you must show them these terms so they know their
rights.

We protect your rights with two steps: (1) copyright the software, and
(2) offer you this license which gives you legal permission to copy,
distribute and/or modify the software.

Also, for each author's protection and ours, we want to make certain
that everyone understands that there is no warranty for this free
software.  If the software is modified by someone else and passed on, we
want its recipients to know that what they have is not the original, so
that any problems introduced by others will not reflect on the original
authors' reputations.

Finally, any free program is threatened constantly by software
patents.  We wish to avoid the danger that redistributors of a free
program will individually obtain patent licenses, in effect making the
program proprietary.  To prevent this, we have made it clear that any
patent must be licensed for everyone's free use or not licensed at all.

The precise terms and conditions for copying, distribution and
modification follow.

GNU GENERAL PUBLIC LICENSE
TERMS AND CONDITIONS FOR COPYING, DISTRIBUTION AND MODIFICATION

0. This License applies to any program or other work which contains
a notice placed by the copyright holder saying it may be distributed
under the terms of this General Public License.  The "Program", below,
refers to any such program or work, and a "work based on the Program"
means either the Program or any derivative work under copyright law:
that is to say, a work containing the Program or a portion of it,
either verbatim or with modifications and/or translated into another
language.  (Hereinafter, translation is included without limitation in
the term "modification".)  Each licensee is addressed as "you".

Activities other than copying, distribution and modification are not
covered by this License; they are outside its scope.  The act of
running the Program is not restricted, and the output from the Program
is covered only if its contents constitute a work based on the
Program (independent of having been made by running the Program).
Whether that is true depends on what the Program does.

1. You may copy and distribute verbatim copies of the Program's
source code as you receive it, in any medium, provided that you
conspicuously and appropriately publish on each copy an appropriate
copyright notice and disclaimer of warranty; keep intact all the
notices that refer to this License and to the absence of any warranty;
and give any other recipients of the Program a copy of this License
along with the Program.

You may charge a fee for the physical act of transferring a copy, and
you may at your option offer warranty protection in exchange for a fee.

2. You may modify your copy or copies of the Program or any portion
of it, thus forming a work based on the Program, and copy and
distribute such modifications or work under the terms of Section 1
above, provided that you also meet all of these conditions:

a) You must cause the modified files to carry prominent notices
stating that you changed the files and the date of any change.

b) You must cause any work that you distribute or publish, that in
whole or in part contains or is derived from the Program or any
part thereof, to be licensed as a whole at no charge to all third
parties under the terms of this License.

c) If the modified program normally reads commands interactively
when run, you must cause it, when started running for such
interactive use in the most ordinary way, to print or display an
announcement including an appropriate copyright notice and a
notice that there is no warranty (or else, saying that you provide
a warranty) and that users may redistribute the program under
these conditions, and telling the user how to view a copy of this
License.  (Exception: if the Program itself is interactive but
does not normally print such an announcement, your work based on
the Program is not required to print an announcement.)

These requirements apply to the modified work as a whole.  If
identifiable sections of that work are not derived from the Program,
and can be reasonably considered independent and separate works in
themselves, then this License, and its terms, do not apply to those
sections when you distribute them as separate works.  But when you
distribute the same sections as part of a whole which is a work based
on the Program, the distribution of the whole must be on the terms of
this License, whose permissions for other licensees extend to the
entire whole, and thus to each and every part regardless of who wrote it.

Thus, it is not the intent of this section to claim rights or contest
your rights to work written entirely by you; rather, the intent is to
exercise the right to control the distribution of derivative or
collective works based on the Program.

In addition, mere aggregation of another work not based on the Program
with the Program (or with a work based on the Program) on a volume of
a storage or distribution medium does not bring the other work under
the scope of this License.

3. You may copy and distribute the Program (or a work based on it,
under Section 2) in object code or executable form under the terms of
Sections 1 and 2 above provided that you also do one of the following:

a) Accompany it with the complete corresponding machine-readable
source code, which must be distributed under the terms of Sections
1 and 2 above on a medium customarily used for software interchange; or,

b) Accompany it with a written offer, valid for at least three
years, to give any third party, for a charge no more than your
cost of physically performing source distribution, a complete
machine-readable copy of the corresponding source code, to be
distributed under the terms of Sections 1 and 2 above on a medium
customarily used for software interchange; or,

c) Accompany it with the information you received as to the offer
to distribute corresponding source code.  (This alternative is
allowed only for noncommercial distribution and only if you
received the program in object code or executable form with such
an offer, in accord with Subsection b above.)

The source code for a work means the preferred form of the work for
making modifications to it.  For an executable work, complete source
code means all the source code for all modules it contains, plus any
associated interface definition files, plus the scripts used to
control compilation and installation of the executable.  However, as a
special exception, the source code distributed need not include
anything that is normally distributed (in either source or binary
form) with the major components (compiler, kernel, and so on) of the
operating system on which the executable runs, unless that component
itself accompanies the executable.

If distribution of executable or object code is made by offering
access to copy from a designated place, then offering equivalent
access to copy the source code from the same place counts as
distribution of the source code, even though third parties are not
compelled to copy the source along with the object code.

4. You may not copy, modify, sublicense, or distribute the Program
except as expressly provided under this License.  Any attempt
otherwise to copy, modify, sublicense or distribute the Program is
void, and will automatically terminate your rights under this License.
However, parties who have received copies, or rights, from you under
this License will not have their licenses terminated so long as such
parties remain in full compliance.

5. You are not required to accept this License, since you have not
signed it.  However, nothing else grants you permission to modify or
distribute the Program or its derivative works.  These actions are
prohibited by law if you do not accept this License.  Therefore, by
modifying or distributing the Program (or any work based on the
Program), you indicate your acceptance of this License to do so, and
all its terms and conditions for copying, distributing or modifying
the Program or works based on it.

6. Each time you redistribute the Program (or any work based on the
Program), the recipient automatically receives a license from the
original licensor to copy, distribute or modify the Program subject to
these terms and conditions.  You may not impose any further
restrictions on the recipients' exercise of the rights granted herein.
You are not responsible for enforcing compliance by third parties to
this License.

7. If, as a consequence of a court judgment or allegation of patent
infringement or for any other reason (not limited to patent issues),
conditions are imposed on you (whether by court order, agreement or
otherwise) that contradict the conditions of this License, they do not
excuse you from the conditions of this License.  If you cannot
distribute so as to satisfy simultaneously your obligations under this
License and any other pertinent obligations, then as a consequence you
may not distribute the Program at all.  For example, if a patent
license would not permit royalty-free redistribution of the Program by
all those who receive copies directly or indirectly through you, then
the only way you could satisfy both it and this License would be to
refrain entirely from distribution of the Program.

If any portion of this section is held invalid or unenforceable under
any particular circumstance, the balance of the section is intended to
apply and the section as a whole is intended to apply in other
circumstances.

It is not the purpose of this section to induce you to infringe any
patents or other property right claims or to contest validity of any
such claims; this section has the sole purpose of protecting the
integrity of the free software distribution system, which is
implemented by public license practices.  Many people have made
generous contributions to the wide range of software distributed
through that system in reliance on consistent application of that
system; it is up to the author/donor to decide if he or she is willing
to distribute software through any other system and a licensee cannot
impose that choice.

This section is intended to make thoroughly clear what is believed to
be a consequence of the rest of this License.

8. If the distribution and/or use of the Program is restricted in
certain countries either by patents or by copyrighted interfaces, the
original copyright holder who places the Program under this License
may add an explicit geographical distribution limitation excluding
those countries, so that distribution is permitted only in or among
countries not thus excluded.  In such case, this License incorporates
the limitation as if written in the body of this License.

9. The Free Software Foundation may publish revised and/or new versions
of the General Public License from time to time.  Such new versions will
be similar in spirit to the present version, but may differ in detail to
address new problems or concerns.

Each version is given a distinguishing version number.  If the Program
specifies a version number of this License which applies to it and "any
later version", you have the option of following the terms and conditions
either of that version or of any later version published by the Free
Software Foundation.  If the Program does not specify a version number of
this License, you may choose any version ever published by the Free Software
Foundation.

10. If you wish to incorporate parts of the Program into other free
programs whose distribution conditions are different, write to the author
to ask for permission.  For software which is copyrighted by the Free
Software Foundation, write to the Free Software Foundation; we sometimes
make exceptions for this.  Our decision will be guided by the two goals
of preserving the free status of all derivatives of our free software and
of promoting the sharing and reuse of software generally.

NO WARRANTY

11. BECAUSE THE PROGRAM IS LICENSED FREE OF CHARGE, THERE IS NO WARRANTY
FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN
OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES
PROVIDE THE PROGRAM "AS IS" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED
OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS
TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE
PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING,
REPAIR OR CORRECTION.

12. IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING
WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MAY MODIFY AND/OR
REDISTRIBUTE THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES,
INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING
OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED
TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY
YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER
PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE
POSSIBILITY OF SUCH DAMAGES."""
	scroll.add_child(lbl_lic)

	var btn_ok := _add_button(con_license, "OK!", Vector2(460, 415), Vector2(75, 30))
	btn_ok.pressed.connect(func():
		con_license.visible = false
		con_credits.visible = true
	)

func _build_dialogs() -> void:
	file_dlg_save = FileDialog.new()
	file_dlg_save.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	file_dlg_save.access = FileDialog.ACCESS_USERDATA
	file_dlg_save.current_file = "SaveGame.lts"
	file_dlg_save.add_filter("*.lts ; Linux Tycoon Save Game")
	file_dlg_save.canceled.connect(unpause_game)
	file_dlg_save.file_selected.connect(func(path: String):
		current_save_path = path
		var f := FileAccess.open(path, FileAccess.WRITE)
		if f:
			f.store_string(GameManager.generate_save_xml())
			f.close()
			GameManager.show_message("Game successfully saved!")
		unpause_game() 
	)
	add_child(file_dlg_save)

	file_dlg_load = FileDialog.new()
	file_dlg_load.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	file_dlg_load.access = FileDialog.ACCESS_USERDATA
	file_dlg_load.add_filter("*.lts ; Linux Tycoon Save Game")
	file_dlg_load.canceled.connect(unpause_game)
	file_dlg_load.file_selected.connect(func(path: String):
		current_save_path = path
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

	for centered in [con_main_menu, con_intro, con_package_selection, con_worker_assignment, con_sacrifice_worker, con_new_release, con_settings, con_confirm_release, con_confirm_quit, con_confirm_desktop, con_confirm_save, con_credits, con_license, con_music]:
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
	if lbl_paused != null:
		lbl_paused.visible = false

func unpause_game() -> void:
	if con_main_menu.visible or con_intro.visible:
		return 
	day_timer.start()
	btn_pause.visible = true
	if lbl_paused != null:
		lbl_paused.visible = GameManager.is_paused

func _on_btn_pause_pressed() -> void:
	GameManager.is_paused = not GameManager.is_paused
	if GameManager.is_paused:
		btn_pause.icon = tex_play
		lbl_paused.visible = true
		_set_desktop_tooltip(btn_pause, "Resume Game")
	else:
		btn_pause.icon = tex_pause
		lbl_paused.visible = false
		_set_desktop_tooltip(btn_pause, "Pause Game")

func _on_day_timer_timeout() -> void:
	if not GameManager.is_paused and GameManager.my_distro != null:
		GameManager.increment_by_a_day()

func _update_system_time() -> void:
	if sys_time_format == 0:
		lbl_sys_time.visible = false
		if lbl_date != null:
			lbl_date.offset_left = 5
	else:
		lbl_sys_time.visible = true
		var t := Time.get_time_dict_from_system()
		if sys_time_format == 1:
			var h: int = t.hour % 12
			if h == 0: h = 12
			var ampm: String = "AM" if t.hour < 12 else "PM"
			lbl_sys_time.text = "%d:%02d %s" % [h, t.minute, ampm]
		elif sys_time_format == 2:
			var h: int = t.hour % 12
			if h == 0: h = 12
			var ampm: String = "AM" if t.hour < 12 else "PM"
			lbl_sys_time.text = "%d:%02d:%02d %s" % [h, t.minute, t.second, ampm]
		elif sys_time_format == 3:
			lbl_sys_time.text = "%02d:%02d" % [t.hour, t.minute]
		elif sys_time_format == 4:
			lbl_sys_time.text = "%02d:%02d:%02d" % [t.hour, t.minute, t.second]
			
		if lbl_date != null:
			lbl_date.offset_left = 5 + lbl_sys_time.get_minimum_size().x

func _on_stats_updated() -> void:
	if GameManager.my_distro == null:
		lbl_date.text = ""
	else:
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
	btn_save_as_top.visible = true 
	lbl_date.visible = true 
	_on_stats_updated()

func _on_release_version_confirmed() -> void:
	pause_game()
	_hide_all_containers()
	release_lbl_text.text = "%s version %d.0 has been successfully released to the public!\n\nNow just sit back and let the fame and riches pour in! (Or get to work on the next version.)" % [
		GameManager.my_distro.name, GameManager.my_distro.version
	]
	center_container(con_new_release)
	for child in con_new_release.get_children():
		if child is CanvasItem:
			child.show()
	con_new_release.visible = true

func _on_new_release_ok_clicked() -> void:
	GameManager.my_distro.release_new_version()
	unpause_game()
	con_new_release.visible = false
	show_main_hud()
	GameManager.show_message("%s version %d.0 released!" % [GameManager.my_distro.name, GameManager.my_distro.released_ver])
