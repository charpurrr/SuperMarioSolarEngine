class_name LazyJump
extends Fall
## A jump that doesn't give you any height.
## Used for actions that look like jumps but don't act like them.

@export var jump_data: PStateAnimData
@export var fall_data: PStateAnimData


func _physics_tick(delta: float):
	super(delta)

	if actor.velocity.y < 0:
		overwrite_animation(jump_data)
	else:
		overwrite_animation(fall_data)


func _trans_rules():
	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	if actor.push_rays.is_colliding() and input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.can_init_wallslide():
		return &"Wallslide"

	if actor.velocity.y > 0:
		return &"Fall"

	return &""
