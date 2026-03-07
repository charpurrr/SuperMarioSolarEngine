class_name WallBoost
extends Walljump
## Using a Ground-Pound Jump to boost off a wall.


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

	if actor.velocity.y > 0:
		return &"Fall"

	return &""
