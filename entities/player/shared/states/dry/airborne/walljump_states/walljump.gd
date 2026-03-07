class_name Walljump
extends PlayerState
## Jumping from a wallslide.

## The acceleration value for when you're moving against the direction you walljumped in.
@export var resistance_accel: float = 0.13
@export var air_decel: float = 0.01
@export var jump_power: float = 8.15
## How much the walljump sends you forwards.
@export var push_power: float = 3


## Direction is the direction in which the walljump sends you.
## By default, it sends you in the opposite of your facing direction,
## but for cases like the spinjump; this needs to be handled manually.
## Direction is an integer type.
func _on_enter(direction):
	movement.walljump_start_y = actor.position.y

	movement.update_direction(direction)
	movement.activate_freefall_timer()

	actor.velocity.y = -jump_power
	actor.velocity.x = push_power * direction

	movement.consec_jumps = 1


func _physics_tick(_delta: float):
	var should_flip: bool

	should_flip = actor.position.y > movement.walljump_start_y + movement.walljump_turn_threshold

	if InputManager.get_x_dir() != movement.facing_direction:
		movement.move_x_analog(resistance_accel, should_flip)
	elif InputManager.is_moving_x():
		movement.move_x_analog(movement.air_accel_step, should_flip)

	movement.apply_gravity(-actor.velocity.y / jump_power)
	movement.decelerate(air_decel * Vector2.RIGHT)


func _trans_rules():
	if input.buffered_input(&"spin"):
		return &"Spin"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if movement.can_init_wallslide(true):
		return &"Wallslide"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		reset_state(-movement.facing_direction)

	if movement.finished_freefall_timer():
		return &"Freefall"

	return &""
