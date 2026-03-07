class_name SwimFlutter
extends PlayerState
## Moving around underwater while holding the jump button.


func _physics_tick(_delta: float):
	movement.accelerate(
		InputManager.get_vec() * movement.swim_accel_step / 2,
		movement.swim_speed,
		0.03125
	)
	movement.radial_friction(0.0625, movement.swim_speed)


func _trans_rules():
	if not Input.is_action_pressed(&"jump"):
		return &"Swim"

	return &""
