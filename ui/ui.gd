class_name UserInterface
extends CanvasLayer
## UI and utility.

@export var life_meter: LifeMeter

@export_category(&"Pause Variables")
@export var screen_manager: ScreenManager
@export var color_blur: ColorRect
@export var game_pause_sfx: SoundEffect
@export var game_unpause_sfx: SoundEffect

@export_category(&"Camera Variables")
@export var zoom_blur_player: AnimationPlayer

@export_category(&"Notification Variables")
@export var notif_scene: PackedScene

@export var notif_list: Node

var current_notifs: Array = []

@export_category(&"Debug Variables")
@export var debug: Control
@export var debug_label: Label
@export var input_display: Control
var displayed_inputs: Dictionary[String, TextureRect]

## These variables are set in [WorldMachine]
var world_machine: WorldMachine
var level_environment: LevelEnvironment

## See [method _set_player].
var player: Player
## See [method _set_camera].
var camera: Camera2D

var hud_enabled: bool = true


func _ready() -> void:
	_toggle_debug()
	_toggle_debug_hitboxes()

	LocalSettings.setting_changed.connect(_setting_changed)
	GameState.paused.connect(_toggle_color_blur)

	if world_machine == null: return

	_set_player()
	_set_camera()

	world_machine.level_reloaded.connect(_set_player)


func _process(_delta) -> void:
	for i in current_notifs:
		if not is_instance_valid(i):
			current_notifs.erase(i)


func _input(event: InputEvent) -> void:
	_pause_logic(event)

	if GameState.is_paused():
		return

	if (
		(event.is_action_pressed(&"camera_zoom_in") and camera.target_zoom != camera.zoom_min) or
		(event.is_action_pressed(&"camera_zoom_out") and camera.target_zoom != camera.zoom_max)
	):
		zoom_blur_player.stop()
		zoom_blur_player.play(&"camera_focus")

	if event.is_action_pressed(&"toggle_hud"):
		get_tree().call_group(&"HUD", &"hide" if hud_enabled else &"show")
		hud_enabled = !hud_enabled

	_display_input(event)


func _setting_changed(key: String, _value: Variant) -> void:
	if key == "debug_toggle":
		_toggle_debug()
	if key == "debug_toggle_collision_shapes":
		_toggle_debug_hitboxes()


func _pause_logic(event: InputEvent) -> void:
	var is_pause := event.is_action_pressed(&"pause")
	var is_cancel := event.is_action_pressed(&"ui_cancel")

	# Only care about pause-related inputs.
	if not is_pause and not is_cancel:
		return

	# Block input during screen transitions.
	if screen_manager.anime_player.is_playing():
		return

	var is_paused := GameState.is_paused()
	var current_screen := screen_manager.current_screen
	var pause_screen: PauseScreen = screen_manager.get_screen(&"PauseScreen")

	# --- PAUSE ---
	if is_pause and not is_paused:
		_pause_game(pause_screen)
		return

	# --- UNPAUSE ---
	if (is_pause or is_cancel) and is_paused and current_screen is PauseScreen:
		_unpause_game(pause_screen)
		return

	# --- RETURN TO PAUSE MENU FROM SUBMENU ---
	if is_cancel and is_paused:
		screen_manager.switch_screen(current_screen, pause_screen)


func _pause_game(pause_screen: PauseScreen):
	game_pause_sfx.play(screen_manager)
	MusicManager.set_stream_paused(true)
	screen_manager.switch_screen(null, pause_screen)
	GameState.emit_signal(&"paused")


func _unpause_game(pause_screen: PauseScreen):
	game_unpause_sfx.play(screen_manager)
	MusicManager.set_stream_paused(false)
	screen_manager.switch_screen(pause_screen, null)
	GameState.emit_signal(&"paused")


func _toggle_color_blur() -> void:
	if not is_instance_valid(color_blur.material):
		return

	color_blur.visible = !color_blur.visible

	if color_blur.visible and level_environment:
		var gradient_map: GradientTexture1D = level_environment.pause_gradient_map

		color_blur.material.set(&"shader_parameter/gradient", gradient_map)


## Creates a visual "notification" type indicator on the screen.
func _push_notif(type: StringName, input: String) -> void:
	var notif: Control = notif_scene.instantiate()

	notif.type = type
	notif.input = input

	if current_notifs != []:
		for i in current_notifs:
			if is_instance_valid(i):
				i.position.y -= 35

	current_notifs.append(notif)
	notif_list.add_child(notif)


func _display_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		return

	var event_name: String = IconMap.get_filtered_name(event)

	var texture_rect := TextureRect.new()

	texture_rect.texture = IconMap.find(event)
	texture_rect.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL

	if event.is_released():
		if displayed_inputs.has(event_name):
			input_display.remove_child(displayed_inputs[event_name])
			displayed_inputs.erase(event_name)
	elif not displayed_inputs.has(event_name):
		displayed_inputs[event_name] = texture_rect
		input_display.add_child(texture_rect)


func _toggle_debug() -> void:
	var toggle := GameState.debug_toggle

	debug.visible = toggle

	if toggle:
		debug.process_mode = Node.PROCESS_MODE_INHERIT
	else:
		debug.process_mode = Node.PROCESS_MODE_DISABLED


func _toggle_debug_hitboxes() -> void:
	var toggle := GameState.debug_toggle_collision_shapes

	get_tree().set_debug_collisions_hint(toggle)
	# This fixes some buggy behavior which causes the changes to not be visible unless the window is resized.
	get_tree().root.emit_signal(&"visibility_changed")


func _set_player() -> void:
	if not world_machine: return

	player = world_machine.level_node.player

	life_meter.max_hp = player.hp

	if not player.health_module.damaged.is_connected(life_meter.take_hit):
		player.health_module.damaged.connect(life_meter.take_hit)


func _set_camera() -> void:
	camera = world_machine.level_node.camera
