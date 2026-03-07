class_name Fall
extends PlayerState
## Falling.


func _on_enter(_param):
	movement.activate_freefall_timer()


func _subsequent_ticks():
	movement.apply_gravity()


func _physics_tick(_delta: float):
	movement.move_x_analog(movement.air_accel_step, true)


func _trans_rules():
	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	if movement.finished_freefall_timer():
		return &"Freefall"

	return &""
