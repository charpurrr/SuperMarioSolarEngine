class_name UserInterface
extends CanvasLayer
## UI and utility.

@export var life_meter: LifeMeter
@export var debug_overlay: DebugOverlay

@export_category(&"Pause Variables")
@export var screen_manager: ScreenManager
@export var color_blur: ColorRect
@export var game_pause_sfx: SoundEffect
@export var game_unpause_sfx: SoundEffect

@export_category(&"Camera Variables")
@export var zoom_blur_player: AnimationPlayer

var hud_enabled: bool = true


func _ready() -> void:
	if WorldMachine.environment:
		var gradient_map: GradientTexture1D = WorldMachine.environment.pause_gradient_map
		color_blur.material.set(&"shader_parameter/gradient", gradient_map)

	if WorldMachine.player:
		life_meter.max_hp = WorldMachine.player.hp

		if not WorldMachine.player.health_module.damaged.is_connected(life_meter.take_hit):
			WorldMachine.player.health_module.damaged.connect(life_meter.take_hit)

		debug_overlay.player = WorldMachine.player


func _input(event: InputEvent) -> void:
	_pause_logic(event)

	if GameState.is_paused():
		return

	_handle_camera_zoom_effect(event, WorldMachine.camera)

	if event.is_action_pressed(&"toggle_hud"):
		get_tree().call_group(&"HUD", &"hide" if hud_enabled else &"show")
		hud_enabled = !hud_enabled


func _pause_logic(event: InputEvent) -> void:
	var is_pause_action: bool = event.is_action_pressed(&"pause")
	var is_cancel_action: bool = event.is_action_pressed(&"ui_cancel")

	# Only care about pause-related inputs.
	if not is_pause_action and not is_cancel_action:
		return

	# Block input during screen transitions.
	if screen_manager.anime_player.is_playing():
		return

	var is_paused: bool = GameState.is_paused()
	var current_screen: Screen = screen_manager.current_screen
	var pause_screen: PauseScreen = screen_manager.get_screen(&"PauseScreen")

	# --- PAUSE ---
	if is_pause_action and not is_paused:
		_pause_game(pause_screen)
		return

	# --- UNPAUSE ---
	if (is_pause_action or is_cancel_action) and is_paused and current_screen == pause_screen:
		_unpause_game(pause_screen)
		return

	# --- RETURN TO PAUSE MENU FROM SUBMENU ---
	if is_cancel_action and is_paused:
		screen_manager.switch_screen(current_screen, pause_screen)


func _pause_game(pause_screen: PauseScreen):
	game_pause_sfx.play(screen_manager)
	MusicManager.set_stream_paused(true)
	screen_manager.switch_screen(null, pause_screen)
	color_blur.show()
	GameState.toggle_pause()


func _unpause_game(pause_screen: PauseScreen):
	game_unpause_sfx.play(screen_manager)
	MusicManager.set_stream_paused(false)
	screen_manager.switch_screen(pause_screen, null)
	color_blur.hide()
	GameState.toggle_pause()


func _handle_camera_zoom_effect(event: InputEvent, camera: Camera2D) -> void:
	if (
		(event.is_action_pressed(&"camera_zoom_in") and camera.target_zoom != camera.zoom_min) or
		(event.is_action_pressed(&"camera_zoom_out") and camera.target_zoom != camera.zoom_max)
	):
		zoom_blur_player.stop()
		zoom_blur_player.play(&"camera_focus")
