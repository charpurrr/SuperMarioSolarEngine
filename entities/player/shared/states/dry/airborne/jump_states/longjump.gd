class_name Longjump
extends PlayerState
## Jumping forwards from a crouch.

@export var jump_power: float = 8.8
## How much the longjump sends you forwards.
@export var push_power: float = 1.2

@export var forward_accel_time: int
@export var backward_accel_time: int

var accel_val: Vector2

## If the activate_freefall_timer() function should be called.
var start_freefall_timer: bool = false


func _on_enter(_param):
	start_freefall_timer = false

	movement.update_direction(sign(movement.get_input_x()))
	movement.consec_jumps = 0

	actor.velocity.y = -jump_power


func _subsequent_ticks(delta: float):
	movement.apply_gravity(delta, -actor.velocity.y / jump_power, 1.2)


func _physics_tick(_delta: float):
	if InputManager.get_x_dir() == movement.facing_direction:
		var forward_accel_step: float = push_power / forward_accel_time
		accel_val = Vector2.RIGHT * forward_accel_step * movement.facing_direction
	else:
		var backward_accel_step: float = push_power / backward_accel_time
		accel_val = Vector2.RIGHT * backward_accel_step * InputManager.get_x_dir()

	movement.accelerate(accel_val, push_power)

	if actor.velocity.y > 0 and not start_freefall_timer:
		start_freefall_timer = true

		movement.activate_freefall_timer()


func _trans_rules():
	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
			return &"Dive"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.is_on_ceiling():
		return &"Fall"

	if movement.finished_freefall_timer():
		return &"Freefall"

	return &""
