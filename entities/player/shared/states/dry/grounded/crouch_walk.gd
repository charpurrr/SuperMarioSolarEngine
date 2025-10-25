class_name Waddle
extends PlayerState
## Walking whilse crouching on the floor.

## On what frames of the walking animation a footstep soundeffect should play.
@export var footstep_frames: Array[int]

## Wether the footstep sound effect has played or not.
var sfx_has_played: bool = false

var current_frame: int
var last_frame: int


func _physics_tick():
	var crouch_walk_speed: float = movement.max_speed / 2

	current_frame = actor.doll.get_frame()

	movement.activate_coyote_timer()
	movement.move_x(0.12, true, crouch_walk_speed)

	current_frame = actor.doll.get_frame()
	actor.doll.speed_scale = actor.vel.x / crouch_walk_speed

	if current_frame != last_frame:
		_play_footstep_sfx()

	last_frame = current_frame


## Play a footstep sound effect depending on the current frame.
func _play_footstep_sfx():
	for frame in footstep_frames:
		if frame == current_frame:
			for sfx_list in sfx_layers:
				sfx_list.play_sfx_at(self)


func _on_exit():
	actor.doll.speed_scale = 1


func _trans_rules():
	if movement.is_slide_slope():
		return &"ButtSlide"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"CrouchSpin"

	if not InputManager.is_moving_x() or actor.is_on_wall():
		return [&"Crouch", [true, false]]

	if not actor.auto_crouch_check.enabled and input.buffered_input(&"jump"):
		if is_equal_approx(actor.vel.x, 0.0) or sign(actor.vel.x) != movement.facing_direction:
			return &"Backflip"
		elif sign(actor.vel.x) == movement.facing_direction:
			return &"Longjump"

	if not Input.is_action_pressed(&"down") and not actor.auto_crouch_check.enabled:
		return &"Idle"

	return &""
