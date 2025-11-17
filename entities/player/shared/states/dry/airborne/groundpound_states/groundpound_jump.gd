class_name GroundPoundJump
extends Jump
## Jumping after landing from a groundpound.


func _trans_rules():
	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding(false, true) and input.buffered_input(&"jump"):
		return [&"WallBoost", -actor.push_rays.get_collide_side()]

	if movement.can_init_wallslide():
		return &"Wallslide"

	if actor.vel.y > 0:
		return fall_state.name

	return &""
