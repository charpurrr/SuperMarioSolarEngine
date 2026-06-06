class_name Spinjump
extends Jump
## Jumping during a grounded spin attack.

@export var air_accel: float = 0.15


func _physics_tick(_delta: float):
	movement.move_x_analog(air_accel, false)


func _subsequent_ticks(delta: float):
	if actor.velocity.y < 0:
		movement.apply_gravity(delta, -actor.velocity.y / jump_power)
	if actor.velocity.y > 0:
		movement.apply_gravity(delta, 1, 2)


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
		return [&"Walljump", [-actor.push_rays.get_collide_side(), true]]

	if movement.can_init_wallslide(true):
		movement.facing_direction = actor.push_rays.get_collide_side()
		movement.update_direction(movement.facing_direction)

		return &"Wallslide"

	return &""
