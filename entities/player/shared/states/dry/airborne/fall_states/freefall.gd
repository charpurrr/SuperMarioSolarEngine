class_name Freefall
extends Fall
## Uninterupted falling at terminal velocity.


func _on_enter(_param):
	movement.consume_freefall_timer()


func _trans_rules():
	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return &"Walljump"

	if movement.can_init_wallslide():
		return &"Wallslide"

	return &""
