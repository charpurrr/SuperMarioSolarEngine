class_name TripleJump
extends Jump
## Third consecutively timed jump.

@export var air_accel: float = 0.15

## If the activate_freefall_timer() function should be called.
var start_freefall_timer: bool = false


func _physics_tick(_delta: float):
	movement.move_x_analog(air_accel, actor.velocity.y < 0)

	if movement.can_release_jump(applied_variation, min_jump_power):
		applied_variation = true
		actor.velocity.y *= 0.5

	if actor.velocity.y > 0 and not start_freefall_timer:
		start_freefall_timer = true

		movement.activate_freefall_timer()


func _trans_rules():
	if not movement.dived and input.buffered_input(&"dive"):
		return [&"Dive", InputManager.get_x_dir()]

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return &"Walljump"

	if actor.is_on_floor():
		return &"Cheer"

	if movement.can_init_wallslide():
		return &"Wallslide"

	if movement.finished_freefall_timer():
		return &"Freefall"

	return &""
