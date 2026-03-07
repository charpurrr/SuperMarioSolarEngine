class_name SwimHard
extends PlayerState
## Pressing jump while underwater to get a short boost.

## Gets added on top of [member PMovement.swim_speed].
@export var extra_boost_speed: float

var boost_speed: float


func _on_enter(_param):
	boost_speed = movement.swim_speed + extra_boost_speed
	actor.velocity = _get_input_vec() * boost_speed


func _physics_tick():
	movement.accelerate(_get_input_vec() * movement.swim_accel_step, boost_speed, 0.03125)
	movement.radial_friction(0.0625, boost_speed)


func _get_input_vec() -> Vector2:
	var input_vec: Vector2 = InputManager.get_vec()

	if input_vec == Vector2.ZERO:
		input_vec = Vector2.from_angle(actor.doll.rotation) * movement.facing_direction

	return input_vec


func _trans_rules():
	if not actor.doll.is_playing():
		if Input.is_action_pressed(&"jump"):
			return &"SwimFlutter"

		return &"Swim"

	return &""
