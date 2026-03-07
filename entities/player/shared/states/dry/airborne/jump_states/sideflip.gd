class_name Sideflip
extends PlayerState
## Jumping after turning.

@export var air_accel: float = 0.1
@export var jump_power: float = 8.8
## How much the sideflip sends you forwards.
@export var push_power: float = 1.2

## If the activate_freefall_timer() function should be called.
var start_freefall_timer: bool = false


func _on_enter(_param):
	start_freefall_timer = false

	movement.update_direction(sign(movement.get_input_x()))
	movement.consec_jumps = 1

	actor.velocity.y = -jump_power
	actor.velocity.x = push_power * InputManager.get_x_dir()


func _subsequent_ticks():
	movement.apply_gravity(-actor.velocity.y / jump_power)


func _physics_tick(_delta: float):
	movement.move_x_analog(air_accel, false)

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
