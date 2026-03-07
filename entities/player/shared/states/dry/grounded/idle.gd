class_name Idle
extends PlayerState
## Default grounded state when there is no input.

@export var idle_animation_data: PStateAnimData
@export var lookup_animation_data: PStateAnimData


func _physics_tick(_delta: float):
	movement.update_prev_direction()
	movement.decelerate(movement.ground_decel_step * Vector2.RIGHT)

	if Input.is_action_pressed(&"up"):
		overwrite_animation(lookup_animation_data)
	else:
		overwrite_animation(idle_animation_data)


func _trans_rules():
	if actor.velocity.x != 0 and input.buffered_input(&"dive"):
		return &"Dive"

	if Input.is_action_pressed(&"crouch"):
		return [&"Crouch", [false, true]]

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if InputManager.get_x_dir() != 0:
		return &"Walk"

	if input.buffered_input(&"jump"):
		return &"DummyJump"

	return &""
