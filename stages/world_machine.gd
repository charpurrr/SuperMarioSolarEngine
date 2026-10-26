extends KeyScene
## The [WorldMachine] handles area loading and behaviour during gameplay.
## It's a container for the level, the user interface, and the player.
## It's always loaded when a level is being played.

signal reloaded

const USER_INTERFACE_SCENE: PackedScene = preload("uid://csf56lkxqqb12")
const PLAYER_CAMERA_SCENE: PackedScene = preload("uid://cnd277snrwca5")

static var stage: Stage
static var environment: StageEnvironment
static var player: Player
static var camera: PlayerCamera
static var ui: UserInterface

@export var stage_scene: PackedScene
@export var player_scene: PackedScene


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"quick_restart"):
		reload_stage()


func load_stage() -> void:
	_bind_stage()
	_bind_player()
	_bind_camera()
	_bind_ui()

	MusicManager.music = stage.music


func deload_stage() -> void:
	if GameState.is_paused():
		GameState.toggle_pause()

	stage.queue_free()
	ui.queue_free()

	player = null
	camera = null

	# Reset static variables.
	Coin.total_reds = 0


## Reloads the current level.
func reload_stage(
		to_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE,
		from_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE
	) -> void:
	if TransitionManager.transitioning: return

	TransitionManager.transition_local(to_overlay, from_overlay)

	TransitionManager.scene_transition.out_trans_finished.connect(_on_out_trans_finished)


func _on_out_trans_finished() -> void:
	TransitionManager.scene_transition.out_trans_finished.disconnect(_on_out_trans_finished)

	deload_stage()
	load_stage()
	reloaded.emit()

	TransitionManager.greenlight_load_in()


func _on_transition_to(_handover: Variant) -> void:
	load_stage()

	TransitionManager.greenlight_load_in()

	print("Successfully loaded: %s" % stage.stage_name)


func _on_transition_from() -> void:
	pass


func _bind_stage():
	assert(is_instance_valid(stage_scene), "Trying to load invalid level.")

	stage = stage_scene.instantiate()

	add_child(stage)

	if stage.environment:
		environment = stage.environment.instantiate()

		stage.add_child(environment)


func _bind_player():
	if player_scene:
		player = player_scene.instantiate()

		stage.add_child(player)
	else:
		push_warning("No Player configured in the WorldMachine.")


func _bind_camera():
	if PLAYER_CAMERA_SCENE:
		camera = PLAYER_CAMERA_SCENE.instantiate()

		camera.focus = player

		stage.add_child(camera)


func _bind_ui():
	if USER_INTERFACE_SCENE:
		ui = USER_INTERFACE_SCENE.instantiate()

		add_child(ui)
	else:
		push_warning("No UserInterface configured in the WorldMachine.")
