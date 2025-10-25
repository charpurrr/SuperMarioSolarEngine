class_name DiveSlide
extends PlayerState
## Sliding on the ground after a dive.


func _on_enter(_param):
	actor.floor_stop_on_slope = false
	actor.doll.rotation = movement.body_rotation


func _physics_tick():
	var normal_angle: float = actor.get_floor_normal().angle()
	var angle: float = normal_angle + TAU / 2 * Math.sign_positive(movement.facing_direction)

	actor.doll.rotation = lerp_angle(actor.doll.rotation, angle, 0.5)
	movement.decelerate(movement.ground_decel_step * Vector2.RIGHT)


func _subsequent_ticks():
	particles[0].emit_at(actor)


func _on_exit():
	actor.floor_stop_on_slope = true
	actor.doll.rotation = 0


func _trans_rules():
	var rollout_check: bool = (
		(InputManager.get_x_dir() == movement.facing_direction or InputManager.get_x_dir() == 0)
		and (input.buffered_input(&"jump") or Input.is_action_pressed(&"jump"))
	)

	if not actor.auto_crouch_check.enabled:
		if movement.can_spin() and input.buffered_input(&"spin"):
			return &"Spin"

		if input.buffered_input(&"dive") and rollout_check == true:
			return &"SuperRollout"
		elif input.buffered_input(&"dive"):
			return &"Dive"
		elif rollout_check == true:
			return &"Rollout"

	if Input.is_action_pressed(&"crouch"):
		if movement.is_slide_slope():
			return &"ButtSlide"

		return [&"Crouch", [true, false]]

	if is_zero_approx(actor.vel.x) or InputManager.get_x_dir() == -movement.facing_direction:
		if actor.auto_crouch_check.enabled:
			return [&"Crouch", [true, false]]

		return &"Idle"

	return &""
