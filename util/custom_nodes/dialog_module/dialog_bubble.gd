@tool
class_name DialogBubble
extends Node2D
## An in-world speech bubble used by [DialogModule] to display ambient NPC dialog.
##
## Handles its own appear/disappear animations and optional proximity detection.
## Position and layout are kept consistent via [method _update_positions] whenever
## the container resizes or [member tail_cut_into_sprite] changes.

## Fired when the [Player] enters the [member detection_area],
## only when [member show_when_close] is [code]true[/code].
signal player_detected
## Fired when the [Player] leaves the [member detection_area],
## only when [member show_when_close] is [code]true[/code].
signal player_lost

## Whether or not the dialog bubble only shows when the [Player]
## is within the [member detection_area].
## Otherwise, the dialog bubble is always shown.
@export var show_when_close: bool = true

## How close the [Player] needs to be in order for the dialog bubble to appear.
## When the player leaves this proximity, the dialog bubble will disappear.
## Only relevant when [member show_when_close] is enabled.
@export_range(0.0, 0.0, 0.05, "or_greater", "hide_control", "suffix:px")
var appear_proximity: float = 200.0:
	set(val):
		appear_proximity = val

		if is_node_ready():
			detection_area_shape.shape.radius = appear_proximity

## How long the bubble takes to appear or disappear.
## Only relevant when [member show_when_close] is enabled.
@export_range(0.0, 0.0, 0.05, "or_greater", "hide_control", "suffix:sec")
var appear_time: float = 0.3

## How many pixels the tail sprite overlaps into the bubble sprite from below.
@export_range(0.0, 0.0, 0.05, "or_greater", "or_less", "hide_control", "suffix:px")
var tail_cut_into_sprite: float:
	set(val):
		tail_cut_into_sprite = val

		if is_node_ready():
			_update_positions()

@export_category("References")
## The area that detects player proximity. Drives [signal player_detected]
## and [signal player_lost] when [member show_when_close] is enabled.
@export var detection_area: Area2D
## The collision shape of [member detection_area]. Its radius is kept in sync
## with [member appear_proximity].
@export var detection_area_shape: CollisionShape2D
## Root transform node for the bubble visuals. Scaled to/from [constant Vector2.ZERO]
## during [method appear] and [method disappear].
@export var bubble_transform: Node2D
## The container that sizes the bubble body around [member label].
@export var container: MarginContainer
## The label that displays the dialog text.
@export var label: RichTextLabel
## The tail sprite that connects the bubble to the NPC.
@export var tail: Sprite2D

## Whether or not the dialog bubble is currently visible.
## This is always [code]true[/code] if [member show_when_close] is [code]false[/code].
## Otherwise, this is [code]true[/code] after [method appear] has ran, and
## [code]false[/code] after [method disappear] is ran.
var is_active: bool = true


func _ready() -> void:
	if not Engine.is_editor_hint() and show_when_close:
		bubble_transform.scale = Vector2.ZERO
		is_active = false


## Grows the dialog bubble to [constant Vector2.ONE] in
## [member appear_time] seconds.
func appear() -> void:
	if bubble_transform.scale != Vector2.ONE:
		var tween := create_tween()
		tween.tween_property(bubble_transform, "scale", Vector2.ONE, appear_time)

		is_active = true


## Shrinks the dialog bubble to [constant Vector2.ZERO] in
## [member appear_time] seconds.
func disappear() -> void:
	if bubble_transform.scale != Vector2.ZERO:
		var tween := create_tween()
		tween.tween_property(bubble_transform, "scale", Vector2.ZERO, appear_time)

		is_active = false


## Positions the tail and bubble body relative to each other.[br][br]
## The tail is centred on its texture height, then nudged up by [member tail_cut_into_sprite].
## The bubble body is pushed up to sit flush above the tail.
func _update_positions() -> void:
	tail.offset.y = tail.texture.get_height() / 2.0
	tail.position.y = -container.position.y - tail_cut_into_sprite
	bubble_transform.position.y = -tail.position.y - tail.texture.get_height()


func _on_detection_area_body_entered(_body: Node2D) -> void:
	if show_when_close:
		player_detected.emit()
		appear()


func _on_detection_area_body_exited(_body: Node2D) -> void:
	if show_when_close:
		player_lost.emit()
		disappear()
