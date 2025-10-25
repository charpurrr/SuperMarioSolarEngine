class_name Crouch
extends PlayerState
## Holding down on the floor.


# The first entry in the array is wether the first frame
# of the crouch animation should be skipped or not,
# the second entry is wether the crouch sound effect should be played or not.
func _on_enter(array):
	if array[0] == true:
		actor.doll.set_frame(1)

	if array[1] == true:
		for sfx_list in sfx_layers:
			sfx_list.play_sfx_at(self)


func _physics_tick():
	movement.update_direction(InputManager.get_x_dir())
	movement.decelerate(0.07 * Vector2.RIGHT)


## Return whether or not you can crouchwalk.
func _can_crouchwalk() -> bool:
	return (
		actor.vel.x == 0
		and InputManager.is_moving_x()
		and not actor.test_move(actor.transform, Vector2(0.1 * movement.facing_direction, 0))
	)


func _trans_rules():
	if movement.is_slide_slope():
		return &"ButtSlide"

	if _can_crouchwalk():
		return &"Waddle"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"CrouchSpin"

	if not actor.auto_crouch_check.enabled and input.buffered_input(&"jump"):
		if is_equal_approx(actor.vel.x, 0.0) or sign(actor.vel.x) != movement.facing_direction:
			return &"Backflip"

		if sign(actor.vel.x) == movement.facing_direction:
			return &"Longjump"

	if not Input.is_action_pressed(&"down") and not actor.auto_crouch_check.enabled:
		return &"Idle"

	return &""
