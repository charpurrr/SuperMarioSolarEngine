extends Node

enum GraphicsMode {
		LOW_RES,
		HIGH_RES,
	}

var current_graphics_mode: GraphicsMode

var debug_toggle: bool = false
var debug_toggle_hitboxes: bool = false

var fullscreened: bool = false

var buses: Dictionary[StringName, AudioBus] = {
	&"Master":
		AudioBus.new(&"Master", "master_volume"),
	&"Music":
		AudioBus.new(&"Music", "bgm_volume"),
	&"SFX":
		AudioBus.new(&"SFX", "sfx_volume"),
	&"Voice":
		AudioBus.new(&"Voice", "voice_volume")
}


func _ready() -> void:
	get_viewport().size_changed.connect(
		func(): WindowSizer.set_global_shader_size(get_viewport().get_visible_rect().size)
	)

	# Run the logic of every setting on ready
	for section in LocalSettings.settings:
		for key in LocalSettings.settings[section]:
			_setting_changed(key, LocalSettings.load_setting(section, key))

	# Run the logic of every setting when it is changed
	LocalSettings.setting_changed.connect(_setting_changed.bind())

	process_mode = Node.PROCESS_MODE_ALWAYS

	buses[&"Music"].update_mute(LocalSettings.load_setting("Audio", "music_muted"))
	debug_toggle = LocalSettings.load_setting("Developer", "debug_toggle")
	debug_toggle_hitboxes = LocalSettings.load_setting("Developer", "debug_toggle_hitboxes")


func _unhandled_input(event) -> void:
	if event.is_action_pressed(&"mute"):
		LocalSettings.change_setting("Audio", "music_muted",!buses[&"Music"].muted)

	# Toggle between fullscreen and last non-fullscreen window scale
	if event.is_action_pressed(&"fullscreen"):
		var scale: int

		if DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN:
			scale = WindowSizer.last_none_fs
		else:
			scale = WindowSizer.MAX_SCALE

		LocalSettings.change_setting("General", "scale", scale)
		WindowSizer.set_win_scale(scale)

	if event.is_action_pressed(&"debug_toggle"):
		debug_toggle = !debug_toggle
		LocalSettings.change_setting("Developer", "debug_toggle", debug_toggle)
	
	if event.is_action_pressed(&"debug_toggle_hitboxes"):
		debug_toggle_hitboxes = !debug_toggle_hitboxes
		LocalSettings.change_setting("Developer", "debug_toggle_hitboxes", debug_toggle_hitboxes)


func _setting_changed(key: String, value: Variant) -> void:
	match key:
		# GENERAL
		"v_sync":
			DisplayServer.window_set_vsync_mode(value)
		"fps_cap":
			Engine.max_fps = [0, 30, 60, 120][value] # 0:INF, 1:30, 2:60, 3: 120
		"scale":
			WindowSizer.set_win_scale(value)
		"graphics":
			match value:
				0:
					current_graphics_mode = GraphicsMode.LOW_RES
					get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
				1:
					current_graphics_mode = GraphicsMode.HIGH_RES
					get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
		# AUDIO
		"music_muted":
			buses[&"Music"].update_mute(value)


func toggle_pause() -> void:
	get_tree().paused = !is_paused()


func is_paused() -> bool:
	return get_tree().paused
