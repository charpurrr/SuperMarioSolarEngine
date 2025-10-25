class_name WorldMachine
extends KeyScene
## The [WorldMachine] handles area loading and behaviour during gameplay.
## It's a container for the level, the user interface, and the player.
## It's always loaded when a level is being played.

signal level_reloaded

## Whether or not [member level_scene] should be automatically loaded.
@export var autoload: bool = true
@export var level_scene: PackedScene

@export_category("Constant")
@export var user_interface: PackedScene

var level_node: Level
var env_node: LevelEnvironment
var ui_node: UserInterface


func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"quick_restart"):
		reload_level()


## Stores a level as a scene, so it can be reloaded.
func store_level_scene(level: Level) -> void:
	var scene = PackedScene.new()
	scene.pack(level)
	level_scene = scene


func load_level(level: Level, store: bool = false) -> void:
	if store:
		store_level_scene(level)

	level_node = level

	add_child(level_node)

	# Reinstantiate and configure environment node.
	if level_node.level_environment:
		# If a level environment is already loaded, get rid of it and replace it with the new one.
		if env_node:
			env_node.queue_free()

		env_node = level_node.level_environment.instantiate()
		env_node.camera = level_node.camera

		level_node.add_child(env_node)

	# Reinstantiate and configure UI node.
	if user_interface:
		ui_node = user_interface.instantiate()
		ui_node.world_machine = self

		add_child(ui_node)

	# Set UI's level environment if both itself and the environment exists.
	if level_node.level_environment and user_interface:
		ui_node.level_environment = env_node

	# Assign player to camera and vice-versa if applicable.
	if level_node.camera is PlayerCamera:
		level_node.player.camera = level_node.camera
		level_node.camera.player = level_node.player

	# Set the appropriate background music.
	MusicManager.music = level_node.level_music

	# Set the camera as current.
	level_node.camera.make_current()


func deload_level() -> void:
	# Unpauses the game if it was paused during the deload.
	if get_tree().paused == true:
		GameState.emit_signal(&"paused")

	# Delete the level and UI.
	level_node.queue_free()
	ui_node.queue_free()
	
	# Reset static variables.
	Coin.total_reds = 0


## Reloads the current level.
func reload_level() -> void:
	TransitionManager.transition_local(SceneTransition.Type.CIRCLE, SceneTransition.Type.CIRCLE)

	await TransitionManager.scene_transition.to_trans_finished

	var new_level: Node2D = level_scene.instantiate()
	deload_level()
	load_level(new_level)
	level_reloaded.emit()

	TransitionManager.greenlight_load_in()


func _on_transition_to(_handover: Variant) -> void:
	if not autoload: return

	assert(is_instance_valid(level_scene), "Trying to load invalid level.")

	var level = level_scene.instantiate()
	load_level(level)

	TransitionManager.greenlight_load_in()


func _on_transition_from() -> void:
	pass
