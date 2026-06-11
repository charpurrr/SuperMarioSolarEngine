@tool
class_name SceneTransition
extends Control
## Class used to instance nice-looking scene transitions.

## Emitted when the "out" transition overlay has finished animating.
signal out_trans_finished

## Emitted by the global TransitionManager.
## Allows the "in" transition to start.[br][br]
## [b]Note[/b]: this is useful for allowing a scene to load
## required objects before the scene transition starts showing the scene.
signal resume

## Emitted when the "in" transition overlay has finished animating.
signal in_trans_finished

## The list of possible overlays.
## [b]Add to this when creating your own overlays.[/b]
enum Type {
	PLAIN,
	CIRCLE,
	INV_CIRCLE,
	BOWSER,
}

@export_group("Debug Preview", "preview_")
## The starting overlay you want to preview.
@export var preview_start: Type

## The time between the start and end of the preview.
@export var preview_wait_time: float = 1.0:
	set(val):
		preview_wait_time = max(0, val)

## The ending overlay you want to preview.
@export var preview_end: Type

## Action button to play the preview with all of the set parameters.
@export_tool_button("Preview", "Play") var preview_action = _preview

@export_category("Overlays")

## The associated overlay node of every [enum Type].[br][br]
## [b]Add to this when creating your own overlays.[/b]
@export var type_associated_nodes: Dictionary[Type, NodePath]

## The [TransitionOverlay] used when transitioning out of a scene.[br][br]
## This gets set during [method start_transition] based on its [code]start_overlay[/code]
## parameter, and gets cleared when the scene transition is finished.
var _out_node: TransitionOverlay
## The [TransitionOverlay] used when transitioning into a scene.[br][br]
## This gets set during [method start_transition] based on its [code]end_overlay[/code]
## parameter, and gets cleared when the scene transition is finished.
var _in_node: TransitionOverlay
## The color used for the entire scene transition.[br][br]
## This gets set during [method start_transition] based on its [code]color[/code]
## parameter, and gets reset to [constant Color.BLACK] when the scene transition is finished.
var _trans_color: Color = Color.BLACK
## The speed used for the entire scene transition.[br][br]
## This gets set during [method start_transition] based on its [code]speed_scale[/code]
## parameter, and gets reset to [code]1.0[/code] when the scene transition is finished.
var _trans_speed: float = 1.0

## Whether or not a scene transition is currently ongoing.
var transitioning: bool = false


func _ready() -> void:
	_hide_children()

	resume.connect(_start_trans_in)


## Start a visual scene transition with customizable parameters.[br][br]
## [b]Note[/b]: this does [u]not[/u] change the actual game scene.
## That is handled by the global TransitionManager.
func start_transition(
		start_overlay: Type,
		end_overlay: Type,
		color: Color = Color.BLACK,
		speed_scale: float = 1.0,
	) -> void:
	var start_node: TransitionOverlay = get_node(type_associated_nodes.get(start_overlay))
	var end_node: TransitionOverlay = get_node(type_associated_nodes.get(end_overlay))

	_out_node = start_node
	_in_node = end_node
	_trans_color = color
	_trans_speed = speed_scale

	_start_trans_out()

	transitioning = true


## Starts the transition out of a scene.
func _start_trans_out() -> void:
	# Blocks mouse input during transitions.
	mouse_filter = Control.MOUSE_FILTER_STOP

	_out_node.show()

	_out_node.play_transition(_trans_color, _trans_speed)
	_out_node.animation.animation_finished.connect(_end_trans_out)


## Signals the end of the "out" transition.
func _end_trans_out(finished_anim: StringName) -> void:
	if finished_anim != &"transition": return
	_out_node.animation.animation_finished.disconnect(_end_trans_out)

	out_trans_finished.emit()


## Starts the transition into a scene.
func _start_trans_in() -> void:
	_out_node.hide()
	_in_node.show()

	_in_node.play_transition(_trans_color, _trans_speed, true)
	_in_node.animation.animation_finished.connect(_end_trans_in)


## Signals the end of the "in" transition.
func _end_trans_in(finished_anim: StringName) -> void:
	if finished_anim != &"transition": return
	_in_node.animation.animation_finished.disconnect(_end_trans_in)

	_in_node.hide()

	# Unblocks mouse input after transitions are finshed.
	mouse_filter = Control.MOUSE_FILTER_IGNORE

	in_trans_finished.emit()

	_clear_trans()


## Resets all scene transition parameters to their default values.
func _clear_trans() -> void:
	_out_node = null
	_in_node = null
	_trans_color = Color.BLACK
	_trans_speed = 1.0

	transitioning = false


## Preview a scene transition by setting debug parameters.
func _preview() -> void:
	if transitioning:
		push_warning("Hold on there pardner, yer too quick!")
		return

	_hide_children()

	start_transition(preview_start, preview_end, Color.WHITE)

	out_trans_finished.connect(_previewOutFinished)


## Manually greenlight the transition to resume after the "out" transition finishes.
func _previewOutFinished() -> void:
	out_trans_finished.disconnect(_previewOutFinished)
	get_tree().create_timer(preview_wait_time).timeout.connect(resume.emit)


## Hides all [TransitionOverlay]s (children of this node).
func _hide_children() -> void:
	for child in get_children():
		child.hide()
