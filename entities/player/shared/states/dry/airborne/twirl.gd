class_name Twirl
extends PlayerState
## Spinning in the air after having airborne spun once already.

## How much the twirl sends you upwards.
@export var spin_power: float = 6

## If the initial spin action has finished or not.
var finished_init: bool


func _on_enter(_param):
	if movement.can_air_action():
		actor.velocity.y = -spin_power

	movement.activate_freefall_timer()
	movement.consume_coyote_timer()


func _subsequent_ticks():
	movement.apply_gravity()


func _physics_tick():
	movement.move_x_analog(movement.air_accel_step, false)

	if not actor.doll.is_playing():
		finished_init = true


func _on_exit():
	finished_init = false

	if actor.is_on_floor():
		movement.update_direction(sign(movement.get_input_x()))


func _trans_rules():
	if actor.is_on_floor():
		return &"Idle"

	if finished_init and movement.can_air_action() and input.buffered_input(&"spin"):
		reset_state()

	if not movement.can_air_action() and input.buffered_input(&"spin"):
		if input.buffered_input(&"jump"):
			return &"Spinjump"

		return &"Spin"

	if not movement.dived and input.buffered_input(&"dive"):
		return [&"Dive", InputManager.get_x_dir()]

	if movement.finished_freefall_timer():
		return &"Freefall"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	return &""
