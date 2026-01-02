@tool
class_name SceneTransition
extends Control
## Class used to instance nice-looking scene transitions.

## Emitted when the "to" transition overlay has finished animating.
signal to_trans_finished

## Emitted by the global TransitionManager.
## Starts the second half of the transitioning process.
signal ready_for_second_half

## Emitted when the "from" transition overlay has finished animating.
signal from_trans_finished

@export_tool_button("Preview", "Play") var preview_action = _preview
@export var preview_to: TransitionOverlay

@export var wait_time: float = 1.0:
	set(val):
		wait_time = max(0, val)

@export var preview_from: TransitionOverlay


func _ready() -> void:
	for child in get_children():
		child.hide()


func start_transition(
		to: TransitionOverlay,
		from: TransitionOverlay,
		color: Color = Color.BLACK,
		speed_scale: float = 1.0,
	) -> void:
	# TRANSITIONING OUT:
	to.show()
	to.play_transition(color, speed_scale)

	# Blocks mouse input during transitions.
	mouse_filter = Control.MOUSE_FILTER_STOP

	await to.animation.animation_finished
	to_trans_finished.emit()

	# Wait for the greenlight from the TransitionManager.
	await ready_for_second_half

	# TRANSITIONING IN:
	to.hide()
	from.show()
	from.play_transition(color, speed_scale, true)

	await from.animation.animation_finished
	from_trans_finished.emit()
	from.hide()

	# Unblocks mouse input.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _preview() -> void:
	_ready()

	start_transition(preview_to, preview_from, Color.WHITE)

	await to_trans_finished
	await get_tree().create_timer(wait_time).timeout
	# Manually greenlight the second half of the transition animation.
	ready_for_second_half.emit()
