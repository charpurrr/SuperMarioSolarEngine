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
@export var preview_start: Type

@export var wait_time: float = 1.0:
	set(val):
		wait_time = max(0, val)

@export var preview_end: Type

@export_category(&"Overlays")
## The list of possible overlays.
## [b]Add to this when creating your own overlays.[/b]
enum Type {
	PLAIN,
	CIRCLE,
	INV_CIRCLE,
}

## The associated overlay node of every [enum Type].
## [b]Add to this when creating your own overlays.[/b]
@export var type_associated_nodes: Dictionary[Type, NodePath]


func _ready() -> void:
	_hide_children()


func start_transition(
		start_overlay: Type,
		end_overlay: Type,
		color: Color = Color.BLACK,
		speed_scale: float = 1.0,
	) -> void:
	var start_node: TransitionOverlay = get_node(type_associated_nodes.get(start_overlay))
	var end_node: TransitionOverlay = get_node(type_associated_nodes.get(end_overlay))

	# TRANSITIONING OUT:
	start_node.show()
	start_node.play_transition(color, speed_scale)

	# Blocks mouse input during transitions.
	mouse_filter = Control.MOUSE_FILTER_STOP

	await start_node.animation.animation_finished
	to_trans_finished.emit()

	# Wait for the greenlight from the TransitionManager.
	await ready_for_second_half

	# TRANSITIONING IN:
	start_node.hide()
	end_node.show()
	end_node.play_transition(color, speed_scale, true)

	await end_node.animation.animation_finished
	from_trans_finished.emit()
	end_node.hide()

	# Unblocks mouse input.
	mouse_filter = Control.MOUSE_FILTER_IGNORE


func _preview() -> void:
	_hide_children()

	start_transition(preview_start, preview_end, Color.WHITE)

	await to_trans_finished
	await get_tree().create_timer(wait_time).timeout
	# Manually greenlight the second half of the transition animation.
	ready_for_second_half.emit()


func _hide_children() -> void:
	for child in get_children():
		child.hide()
