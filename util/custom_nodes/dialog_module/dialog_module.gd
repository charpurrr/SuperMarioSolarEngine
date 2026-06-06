@tool
class_name DialogModule
extends Node2D
## Provides the parent node with dialog features, including full dialog sequences
## and cycling in-world speech bubbles.
##
## Attach this as a child of any NPC or interactable that needs dialog behaviour.
## Configure [member dialog] for full dialog sequences and the [code]bubble_*[/code]
## properties for ambient speech bubbles.

## Possible phases of a bubble dialog cycle.
enum BubbleCycleState {
	IDLE, ## No cycle is running.
	SHOWING, ## A bubble is currently visible, waiting before cycling to the next.
	COOLDOWN, ## The bubble has just disappeared, brief pause before the next one appears.
}

## Minimum pause (in seconds) between bubble dialog cycles when [member bubble_dialog] contains
## multiple entries. Kept as a constant to stay consistent across all [DialogModule]s.
const BUBBLE_DIALOG_CYCLE_COOLDOWN: float = 0.3

## The dialog entries used for full dialog sequences (e.g. triggered by player interaction).
@export var dialog: Array[DialogEntry]

@export_group("Show Bubble", "bubble_")

## Master toggle for the in-world speech bubble. Disabling this hides all related properties.
@export_custom(PROPERTY_HINT_GROUP_ENABLE, "") var bubble_show: bool:
	set(val):
		bubble_show = val
		notify_property_list_changed()

## If [code]true[/code], the bubble only appears when the player is within
## [member bubble_proximity] of this node. See [member DialogBubble.show_when_close].
@export var bubble_show_when_close: bool = true:
	set(val):
		bubble_show_when_close = val
		notify_property_list_changed()

## Radius within which the player must be for the bubble to appear.
## Has no effect if [member bubble_show_when_close] is [code]false[/code].
@export_range(0.0, 0.0, 0.05, "or_greater", "hide_control", "suffix:px")
var bubble_proximity: float = 200.0:
	set(val):
		bubble_proximity = val

		if is_instance_valid(bubble_node):
			bubble_node.appear_proximity = val

## The pool of text strings the bubble can display. If more than one entry is provided,
## the bubble cycles through them using [member bubble_dialog_cycle_time].
@export var bubble_dialog: PackedStringArray

## How long each bubble entry stays visible before cycling to the next.
## Only used when [member bubble_dialog] has more than one entry.
@export_range(0.0, 0.0, 0.05, "or_greater", "hide_control", "suffix:sec")
var bubble_dialog_cycle_time: float = 3.0:
	set(val):
		bubble_dialog_cycle_time = val

		if is_instance_valid(bubble_cycle_timer):
			bubble_cycle_timer.wait_time = val

## If [code]true[/code], picks the next bubble dialog entry at random instead of sequentially.
## Only used when [member bubble_dialog] has more than one entry.
@export var bubble_dialog_randomized: bool = false

## Editor-only preview: set this to an index in [member bubble_dialog] to preview
## that entry in the bubble without running the scene.
@export var bubble_editor_preview_dialog_idx: int:
	set(val):
		if (
			not is_node_ready() or
			bubble_dialog.is_empty() or
			not Engine.is_editor_hint() or
			not is_instance_valid(bubble_node)
		):
			bubble_node.label.text = ""
			return

		bubble_editor_preview_dialog_idx = clampi(val, 0, bubble_dialog.size() - 1)
		bubble_node.label.text = bubble_dialog[bubble_editor_preview_dialog_idx]

@export_category("References")
## The packed scene used to instantiate the full dialog UI.
@export var dialog_ui: PackedScene
## The packed scene used to instantiate the in-world [DialogBubble].
@export var dialog_bubble: PackedScene
## Timer that drives bubble cycling.
@export var bubble_cycle_timer: Timer

## The instantiated [DialogBubble] node. Only valid when [member bubble_show] is [code]true[/code].
var bubble_node: DialogBubble = null
## Index of the currently displayed entry within [member bubble_dialog].
var current_bubble_dialog_idx: int = 0
## Current phase of the bubble cycling state machine.
var bubble_cycle_state: BubbleCycleState = BubbleCycleState.IDLE


func _ready() -> void:
	if bubble_show:
		_create_bubble()

		bubble_cycle_timer.timeout.connect(_on_cycle_timer_timeout)

		if bubble_show_when_close:
			bubble_node.player_detected.connect(_start_bubble_cycle)
			bubble_node.player_lost.connect(_stop_bubble_cycle)
		else:
			_start_bubble_cycle()


## Begins the bubble cycling loop if there are multiple dialog entries and no cycle is running.
func _start_bubble_cycle() -> void:
	if bubble_dialog.size() > 1 and bubble_cycle_state == BubbleCycleState.IDLE:
		bubble_cycle_state = BubbleCycleState.SHOWING
		bubble_cycle_timer.start(bubble_dialog_cycle_time)


## Stops the bubble cycling loop and resets the state to [constant BubbleCycleState.IDLE].
func _stop_bubble_cycle() -> void:
	bubble_cycle_state = BubbleCycleState.IDLE
	bubble_cycle_timer.stop()


## Advances the bubble cycle state machine on each timer tick.[br][br]
## [constant BubbleCycleState.SHOWING]: hides the current bubble and enters cooldown.[br]
## [constant BubbleCycleState.COOLDOWN]: picks the next dialog entry and shows a new bubble.
func _on_cycle_timer_timeout() -> void:
	if not is_instance_valid(bubble_node):
		_stop_bubble_cycle()
		return

	if bubble_show_when_close and not bubble_node.detection_area.has_overlapping_bodies():
		_stop_bubble_cycle()
		return

	match bubble_cycle_state:
		BubbleCycleState.SHOWING:
			bubble_node.disappear()
			bubble_cycle_state = BubbleCycleState.COOLDOWN
			bubble_cycle_timer.start(BUBBLE_DIALOG_CYCLE_COOLDOWN)

		BubbleCycleState.COOLDOWN:
			if bubble_dialog_randomized:
				var randi_idx := current_bubble_dialog_idx
				while randi_idx == current_bubble_dialog_idx:
					randi_idx = randi_range(0, bubble_dialog.size() - 1)
				current_bubble_dialog_idx = randi_idx
			else:
				current_bubble_dialog_idx = wrapi(
					current_bubble_dialog_idx + 1,
					0,
					bubble_dialog.size()
				)

			bubble_node.label.text = bubble_dialog[current_bubble_dialog_idx]
			bubble_node.appear()

			bubble_cycle_state = BubbleCycleState.SHOWING
			bubble_cycle_timer.start(bubble_dialog_cycle_time)


## Instantiates [member dialog_bubble], sets its initial text and proximity, and adds it as a child.
func _create_bubble() -> void:
	bubble_node = dialog_bubble.instantiate()
	bubble_node.show_when_close = bubble_show_when_close

	if not bubble_dialog.is_empty():
		if bubble_dialog_randomized:
			current_bubble_dialog_idx = randi_range(0, bubble_dialog.size() - 1)
		else:
			current_bubble_dialog_idx = 0

		bubble_node.label.text = bubble_dialog[current_bubble_dialog_idx]
	else:
		bubble_node.label.text = ""

	add_child(bubble_node)


func _validate_property(property: Dictionary) -> void:
	if not bubble_show or not bubble_show_when_close:
		if property.name == "bubble_proximity":
			property.usage = PROPERTY_USAGE_NO_EDITOR
