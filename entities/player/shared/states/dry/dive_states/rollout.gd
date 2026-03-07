class_name DiveRollout
extends Jump
## Jumping out of a dive slide.

## The multiplier applied to your current horizontal speed after a rollout.
@export_range(1, 10) var x_multiplier: float = 1.3
## The maximum horizontal speed you need to reach before rollouts
## no longer contribute to your x velocity.
@export var accel_cap: float = 10.0


func _on_enter(_param):
	movement.consume_coyote_timer()
	movement.activate_freefall_timer()

	actor.velocity.y = -jump_power

	if abs(actor.velocity.x) < accel_cap:
		if abs(actor.velocity.x) > accel_cap / x_multiplier:
			actor.velocity.x = accel_cap * movement.facing_direction
		else:
			actor.velocity.x *= x_multiplier


func _trans_rules():
	if (
		not movement.dived
		and movement.can_air_action()
		and actor.velocity.y > 0
		and (input.buffered_input(&"dive") or Input.is_action_pressed(&"dive"))
	):
		return &"Dive"

	if actor.is_on_floor():
		return &"Idle"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	return &""
