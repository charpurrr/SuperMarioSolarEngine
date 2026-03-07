class_name Swim
extends PlayerState
## Moving around underwater.


func _physics_tick(_delta: float):
	movement.accelerate(
		InputManager.get_vec() * movement.swim_accel_step,
		movement.swim_speed,
		0.03125
	)
	movement.radial_friction(0.125, movement.swim_speed)


func _trans_rules():
	if not InputManager.is_moving_any():
		return &"SwimIdle"

	if input.buffered_input(&"spin"):
		return &"SwimSpin"

	if input.buffered_input(&"jump"):
		return &"SwimHard"

	return &""
