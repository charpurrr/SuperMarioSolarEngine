class_name EnterPipe
extends PlayerState
## Enter pipe state.

## How quickly the [Player] lines up with the [WarpPipe]'s [member position.x].
@export_range(0.0, 0.0, 0.005, "or_greater","hide_control", "suffix:sec") \
var lineup_x_speed := 0.5
#@export_range(0.0, 1.0, 0.005) var lineup_lerp_speed := 0.3
## How far into the [WarpPipe]'s entrance the [Player] goes before transitioning.
@export var enter_distance := 32
## The distance the [Player] travels every frame while entering the [WarpPipe].
@export var enter_step := 1.0

## What x coodinate to lerp towards during this state.
var target_pos_x: float
## What y coordinate the [Player] started entering the [Pipe] from.
var start_pos_y: float

var lineup_tween: Tween

var entering := false


func _on_enter(entrance_pos_x: Variant) -> void:
	actor.velocity = Vector2.ZERO
	actor.doll.flip_h = actor.position.x > entrance_pos_x

	target_pos_x = entrance_pos_x
	start_pos_y = actor.position.y

	entering = false


func _physics_tick(_delta: float) -> void:
	if not lineup_tween:
		lineup_tween = create_tween()
		lineup_tween.tween_property(actor, "position", Vector2(target_pos_x, start_pos_y), lineup_x_speed)
		lineup_tween.set_ease(Tween.EASE_OUT)
		lineup_tween.finished.connect(func(): entering = true)

	if entering:
		_enter()


func _enter() -> void:
	if actor.position.y == start_pos_y + enter_distance:
		entering = false

	actor.position.y += enter_step
