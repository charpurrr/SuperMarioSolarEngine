class_name Spinjump
extends Jump
## Jumping during a grounded spin attack.


func _physics_tick():
	movement.move_x_analog(0.15, false)


func _subsequent_ticks():
	if actor.velocity.y < 0:
		movement.apply_gravity(-actor.velocity.y / jump_power)
	if actor.velocity.y > 0:
		movement.apply_gravity(1, 2)


func _trans_rules():
	if actor.is_on_floor():
		return &"Idle"

	if actor.is_on_ceiling():
		return &"Fall"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if actor.velocity.y > 0 and input.buffered_input(&"spin"):
		movement.update_direction(InputManager.get_x_dir())
		return &"Twirl"

	if movement.finished_freefall_timer():
		return &"Freefall"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding(false, true) and input.buffered_input(&"jump"):
		return [&"Walljump", -actor.push_rays.get_collide_side()]

	if movement.can_init_wallslide(true):
		movement.facing_direction = actor.push_rays.get_collide_side()
		movement.update_direction(movement.facing_direction)

		return &"Wallslide"

	return &""
