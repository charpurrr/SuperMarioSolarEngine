extends CanvasLayer
## Helper that allows for switching scenes with an animation effect.
## Also supports keeping the scene transition purely visual.

## Emit this only your scene is ready to be loaded in.[br][br]
## [b]Note[/b]: this is useful for allowing a scene to load
## required objects before the scene transition starts showing the scene.
signal greenlight

## The [KeyScene] that's currently loaded in.
var current_key_scene: KeyScene

## The path to the [KeyScene] we are transitioning to.[br][br]
## This gets set during [method transition_scene] based on its [code]new_scene_path[/code]
## parameter, and gets cleared when the scene transition is finished.
var new_key_scene_path: String = ""
## Optional data that gets transferred over from the old scene when
## transitioning to the new one.[br][br]
## This gets set during [method transition_scene] based on its [code]handover[/code]
## parameter, and gets cleared when the scene transition is finished.
var new_scene_handover: Variant = null

var new_scene_load_progress: Array = []

## Whether or not the TransitionManager is currently in a transition.
var transitioning: bool = false

## Reference to the scene transition node.
@onready var scene_transition: SceneTransition = $SceneTransition


## Plays a transition effect and loads in a new scene.
func transition_scene(
		new_scene_path: String,
		start_overlay: SceneTransition.Type,
		end_overlay: SceneTransition.Type,
		handover: Variant = null,
		color = Color.BLACK,
		speed_scale = 1.0
	) -> void:
	if transitioning: return
	transitioning = true

	assert(ResourceLoader.exists(new_scene_path), "Given scene doesn't exist!")
	ResourceLoader.load_threaded_request(new_scene_path, "PackedScene")

	new_key_scene_path = new_scene_path
	new_scene_handover = handover

	scene_transition.start_transition(
		start_overlay,
		end_overlay,
		color,
		speed_scale
	)

	_load_out()


## Plays a transition effect without changing scenes.
func transition_local(
		start_overlay: SceneTransition.Type,
		end_overlay: SceneTransition.Type,
		color = Color.BLACK,
		speed_scale = 1.0
	) -> void:
	if transitioning: return
	transitioning = true

	scene_transition.start_transition(
		start_overlay,
		end_overlay,
		color,
		speed_scale
	)

	scene_transition.out_trans_finished.connect(_connect_greenlight)


## Allows the scene transition to end.[br][br]
## [b]Note[/b]: this is useful for allowing a scene to load
## required objects before the scene transition starts showing the scene.
func greenlight_load_in() -> void:
	greenlight.emit()


func _load_out() -> void:
	current_key_scene._on_transition_from()
	scene_transition.out_trans_finished.connect(_change_scene)


func _change_scene() -> void:
	scene_transition.out_trans_finished.disconnect(_change_scene)

	var load_status: ResourceLoader.ThreadLoadStatus

	while true:
		load_status = ResourceLoader.load_threaded_get_status(
			new_key_scene_path, new_scene_load_progress)

		match load_status:
			ResourceLoader.THREAD_LOAD_IN_PROGRESS:
				print("Scene load progress: %s" % new_scene_load_progress[-1])
			ResourceLoader.THREAD_LOAD_LOADED:
				break

		await get_tree().process_frame

	var packed_scene: PackedScene = ResourceLoader.load_threaded_get(new_key_scene_path)

	var tree: SceneTree = get_tree()
	tree.change_scene_to_packed(packed_scene)

	tree.scene_changed.connect(_load_scene)


func _load_scene() -> void:
	var tree: SceneTree = get_tree()
	tree.scene_changed.disconnect(_load_scene)

	_connect_greenlight()

	current_key_scene._on_transition_to(new_scene_handover)


func _connect_greenlight() -> void:
	if scene_transition.out_trans_finished.is_connected(_connect_greenlight):
		scene_transition.out_trans_finished.disconnect(_connect_greenlight)

	greenlight.connect(_load_in)


func _load_in() -> void:
	greenlight.disconnect(_load_in)

	scene_transition.resume.emit()

	scene_transition.in_trans_finished.connect(_end_scene_transition)


func _end_scene_transition() -> void:
	scene_transition.in_trans_finished.disconnect(_end_scene_transition)

	new_key_scene_path = ""
	new_scene_handover = null
	transitioning = false
