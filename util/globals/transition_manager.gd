extends CanvasLayer
## Handles visual screen transitions.
## Has the ability to transition between scenes too.

## Emit this when your scene is ready to be loaded in
## after the first half of a scene transition.
signal ready_for_load_in

@export var scene_transition: SceneTransition

## The [KeyScene] we are transitioning from.
var current_key_screen


## Plays a transition effect and loads in a new scene.
func transition_scene(
		new_scene_uid: String,
		start_overlay: SceneTransition.Type,
		end_overlay: SceneTransition.Type,
		handover: Variant = null,
		color = Color.BLACK,
		speed_scale = 1.0
	) -> void:
	assert(ResourceLoader.exists(new_scene_uid), "Given scene doesn't exist!")

	scene_transition.start_transition(
		start_overlay,
		end_overlay,
		color,
		speed_scale
	)

	# Load OUT
	current_key_screen._on_transition_from()
	await scene_transition.to_trans_finished

	# Load IN
	var tree: SceneTree = get_tree()
	tree.change_scene_to_file(new_scene_uid)

	# Greenlights the [SceneTransition] to start the load-in animation.
	await tree.scene_changed
	current_key_screen._on_transition_to(handover)

	await ready_for_load_in
	scene_transition.ready_for_second_half.emit()


## Plays a transition effect without changing scenes.
func transition_local(
		start_overlay: SceneTransition.Type,
		end_overlay: SceneTransition.Type,
		color = Color.BLACK,
		speed_scale = 1.0
	) -> void:
	scene_transition.start_transition(
		start_overlay,
		end_overlay,
		color,
		speed_scale
	)

	await scene_transition.to_trans_finished
	await ready_for_load_in
	scene_transition.ready_for_second_half.emit()


func greenlight_load_in() -> void:
	# Deferred to sync up all the possible awaits first.
	call_deferred("emit_signal", "ready_for_load_in")
