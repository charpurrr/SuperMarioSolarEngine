class_name Bonk
extends PlayerState
## Bonk against a wall

## Horizontal knockback from bonking against a wall.
@export var wall_kickback_power_x: float = 1.7
## Vertical knockback from bonking against a wall.
@export var wall_kickback_power_y: float = 1.5

## How long it takes to fully rotate the bonking animation,
## Thus allowing you to perform moves again.
## [br][br] (in frames)
@export var rotation_time: float
var rotation_timer: float

var finished_rotating: bool


func _on_enter(_param):
	movement.activate_freefall_timer()

	actor.velocity.x = wall_kickback_power_x * actor.get_wall_normal().x
	actor.velocity.y = -wall_kickback_power_y

	rotation_timer = 0


func _subsequent_ticks():
	movement.apply_gravity()


func _physics_tick():
	rotation_timer = min(rotation_timer + 1, rotation_time)

	actor.doll.rotation = (
		_rotation_math(rotation_timer / rotation_time) * -TAU / 8 * movement.facing_direction
	)

	if rotation_timer == rotation_time:
		finished_rotating = true


func _rotation_math(time: float) -> float:
	return 1 - pow(time - 1, 2)


func _on_exit():
	actor.doll.rotation = 0

	finished_rotating = false


func _trans_rules():
	if actor.is_on_floor():
		return &"Idle"

	if finished_rotating:
		if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
			return &"Dive"

		if movement.can_air_action() and input.buffered_input(&"spin"):
			return &"Twirl"

		if movement.finished_freefall_timer():
			return &"Freefall"

		if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
			return &"GroundPound"

	return &""
