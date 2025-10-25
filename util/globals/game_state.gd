extends Node

signal setting_initialised(key: String, value: Variant)

signal paused

enum Qualities {
		LOW = 0, ## Optimised for performance. Enables viewport stretching and disables most shaders.
		MEDIUM = 1, ## Balanced performance. Enables viewport stretching but keeps most shaders enabled.
		HIGH = 2, ## Best visuals experience. Enables canvas item stretching and keeps most shaders enabled.
	}
var quality: Qualities

var debug_toggle: bool = false
var debug_toggle_collision_shapes: bool = false

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


func _ready():
	paused.connect(pause_toggle)

	get_viewport().size_changed.connect(
		func(): WindowSizer.set_global_shader_size(get_viewport().get_visible_rect().size)
	)

	# Run the logic of every setting on ready
	setting_initialised.connect(_setting_changed.bind())
	# Run the logic of every setting when it is changed
	LocalSettings.setting_changed.connect(_setting_changed.bind())

	process_mode = Node.PROCESS_MODE_ALWAYS

	buses[&"Music"].update_mute(LocalSettings.load_setting("Audio", "music_muted", false))
	debug_toggle = LocalSettings.load_setting("Developer", "debug_toggle", false)
	debug_toggle_collision_shapes = LocalSettings.load_setting("Developer", "debug_toggle_collision_shapes", false)


func _unhandled_input(event):
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
	
	if event.is_action_pressed(&"debug_toggle_collision_shapes"):
		debug_toggle_collision_shapes = !debug_toggle_collision_shapes
		LocalSettings.change_setting("Developer", "debug_toggle_collision_shapes", debug_toggle_collision_shapes)


func _setting_changed(key: String, value: Variant):
	match key:
		# GENERAL
		"v_sync":
			DisplayServer.window_set_vsync_mode(value)
		"fps_cap":
			Engine.max_fps = [0, 30, 60, 120][value] # 0:INF, 1:30, 2:60, 3: 120
		"scale":
			WindowSizer.set_win_scale(value)
		"quality":
			match value:
				0: # HIGH
					quality = Qualities.HIGH
					get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
				1: # LOW
					quality = Qualities.LOW
					get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
				2: # MEDIUM
					quality = Qualities.MEDIUM
					get_tree().root.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT
		# AUDIO
		"music_muted":
			buses[&"Music"].update_mute(value)


## Called with the paused signal.
func pause_toggle():
	get_tree().paused = !is_paused()


func is_paused() -> bool:
	return get_tree().paused
