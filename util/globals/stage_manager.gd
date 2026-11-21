extends KeyScene
## The [StageManager] handles area loading and behaviour during gameplay.
## It's a container for the level, the user interface, and the player.
## It's always loaded when a level is being played.

const USER_INTERFACE_SCENE: PackedScene = preload("uid://csf56lkxqqb12")
const PLAYER_CAMERA_SCENE: PackedScene = preload("uid://cnd277snrwca5")

static var stage: Stage
static var environment: StageEnvironment
static var player: Player
static var camera: PlayerCamera
static var ui: UserInterface

## The manifest for this stage (areas, tracked IDs, totals). Optional: without it
## the manager falls back to [member stage_scene] and no progress is tracked.
@export var stage_data: StageData
## Fallback / quick-testing scene, used when there is no [member stage_data].
@export var stage_scene: PackedScene
@export var player_scene: PackedScene

## True when the next load should put the player at the last checkpoint
## instead of at a spawn point (respawn after death / quick restart).
var _spawn_at_checkpoint: bool = false


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


## Completely restarts the stage, clearing all previous data.
func restart_stage(
		to_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE,
		from_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE
	) -> void:
		if TransitionManager.transitioning: return

		_begin_session()
		reload_stage(to_overlay, from_overlay)


## Respawns the player. Anything not locked in by a checkpoint is lost
## (see [TrackPolicies]), then the stage is reloaded at the last checkpoint,
## or at the start if none was reached.
func reload_stage(
		to_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE,
		from_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE
	) -> void:
	if TransitionManager.transitioning: return

	StageCache.on_death()

	_spawn_at_checkpoint = StageCache.has_checkpoint()

	if _spawn_at_checkpoint:
		StageCache.current_area = StageCache.checkpoint_area
	elif stage_data:
		StageCache.current_area = stage_data.start_area
		StageCache.spawn_id = stage_data.start_spawn

	_run_transition(to_overlay, from_overlay)


## Moves to another area of the same [Stage]. Called by teleporters.
## Session data carries over untouched.
func change_area(
		area_id: StringName,
		spawn_id: StringName,
		to_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE,
		from_overlay: SceneTransition.Type = SceneTransition.Type.CIRCLE
	) -> void:
	if TransitionManager.transitioning: return

	assert(stage_data and stage_data.areas.has(area_id), "Unknown area: %s" % area_id)

	StageCache.current_area = area_id
	StageCache.spawn_id = spawn_id

	_spawn_at_checkpoint = false

	_run_transition(to_overlay, from_overlay)


## Call when the end of the [Stage] is reached. Locks in pending progress and writes the save.
func finish_stage() -> void:
	if stage_data == null: return

	StageCache.commit_pending()

	var record: StageRecord = SaveManager.profile.record_for(stage_data.id)
	record.merge(StageCache.results())

	SaveManager.save_profile()


func _run_transition(
		to_overlay: SceneTransition.Type,
		from_overlay: SceneTransition.Type
	) -> void:
	TransitionManager.transition_local(to_overlay, from_overlay)

	TransitionManager.scene_transition.out_trans_finished.connect(_on_out_trans_finished)


func _on_out_trans_finished() -> void:
	TransitionManager.scene_transition.out_trans_finished.disconnect(_on_out_trans_finished)

	deload_stage()
	load_stage()

	TransitionManager.greenlight_load_in()


func _on_transition_to(_handover: Variant) -> void:
	_spawn_at_checkpoint = false
	_begin_session()

	load_stage()

	TransitionManager.greenlight_load_in()

	print("Successfully loaded: %s" % stage.stage_name)


func _on_transition_from() -> void:
	pass


## Resets the per-run state and snapshots what the player already owns.
func _begin_session() -> void:
	if stage_data == null: return

	# Drop saved IDs that no longer exist in the level before snapshotting.
	SaveManager.prune_stage(stage_data)

	var record: StageRecord = SaveManager.profile.record_for(stage_data.id)

	StageCache.begin(stage_data, record)
	StageCache.current_area = stage_data.start_area
	StageCache.spawn_id = stage_data.start_spawn

	_spawn_at_checkpoint = false


func _get_area_scene() -> PackedScene:
	if stage_data and stage_data.areas.has(StageCache.current_area):
		return stage_data.areas[StageCache.current_area]

	return stage_scene


func _bind_stage():
	var area_scene: PackedScene = _get_area_scene()

	assert(is_instance_valid(area_scene), "Trying to load invalid area.")

	stage = area_scene.instantiate()

	add_child(stage)

	if stage.environment:
		environment = stage.environment.instantiate()

		stage.add_child(environment)

	_activate_saved_checkpoint()


func _bind_player():
	if player_scene:
		player = player_scene.instantiate()

		var checkpoint: Checkpoint = _find_checkpoint(StageCache.checkpoint_uuid)

		if _spawn_at_checkpoint and checkpoint:
			player.global_position = checkpoint.global_position + checkpoint.spawn_data.offset
			player.velocity = checkpoint.spawn_data.starting_velocity
		else:
			var spawn: Node = _find_spawn_point(StageCache.spawn_id)

			player.global_position = spawn.global_position + spawn.spawn_data.offset
			player.velocity = spawn.spawn_data.starting_velocity

		stage.add_child(player)
	else:
		push_warning("No Player configured in the StageManager.")


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
		push_warning("No UserInterface configured in the StageManager.")


func _find_spawn_point(spawn_id: StringName) -> Node:
	var spawns: Array[Node] = get_tree().get_nodes_in_group(&"player_spawn_points")

	assert(not spawns.is_empty(), "Area has no player spawn point.")

	for spawn: Node in spawns:
		if spawn.name == spawn_id:
			return spawn

	return spawns[0]


func _find_checkpoint(uuid: String) -> Checkpoint:
	if uuid.is_empty(): return null

	for checkpoint: Checkpoint in get_tree().get_nodes_in_group(&"checkpoints"):
		if checkpoint.uuid == uuid:
			return checkpoint

	return null


## Marks the saved checkpoint as already active if it's in the loaded area,
## so it doesn't re-trigger when the player walks past it again.
func _activate_saved_checkpoint() -> void:
	var checkpoint: Checkpoint = _find_checkpoint(StageCache.checkpoint_uuid)

	if checkpoint:
		checkpoint.active = true
