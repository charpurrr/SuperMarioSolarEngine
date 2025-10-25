class_name Walk
extends PlayerState
## Moving left and right on the ground.

## On what frames of the walking animation a footstep soundeffect should play.
@export var footstep_frames: Array[int]

@export_category(&"Animation (Unique to State)")
@export var walk_animation_data: PStateAnimData
@export var run_animation_data: PStateAnimData

## Wether the footstep sound effect has played or not.
var sfx_has_played: bool = false

var current_frame: int
var last_frame: int


func _physics_tick():
	current_frame = actor.doll.get_frame()

	movement.update_prev_direction()
	movement.activate_coyote_timer()
	movement.move_x_analog(movement.ground_accel_step, true, movement.ground_decel_step)

	actor.doll.speed_scale = actor.vel.x / movement.max_speed * 2
	_set_appropriate_anim()

	if current_frame != last_frame:
		for frame in footstep_frames:
			if frame == current_frame:
				particles[0].emit_at(actor) # Emit the first particle (dust kick) every footstep.
				_play_footstep_sfx()

	last_frame = current_frame


## Sets either the walking or running animation depending on velocity.
func _set_appropriate_anim():
	if snappedf(abs(actor.vel.x), 3) > movement.max_speed:
		overwrite_animation(run_animation_data)
		actor.vel.x = move_toward(actor.vel.x, movement.max_speed * movement.facing_direction, 0.1)
	else:
		overwrite_animation(walk_animation_data)


## Play the footstep sound effect.
func _play_footstep_sfx():
	# Normal footsteps
	sfx_layers[0].play_sfx_at(self)
	# FLUDD footsteps
	if FluddManager.active_nozzle != FluddManager.Nozzle.NONE:
		sfx_layers[1].play_sfx_at(self)


func _on_exit():
	actor.doll.speed_scale = 1


func _trans_rules():
	if input.buffered_input(&"dive"):
		return &"Dive"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"DummyJump"

	if InputManager.get_x_dir() == -movement.prev_facing_direction and abs(actor.vel.x) > 1:
		movement.update_prev_direction()
		return [&"Skid", [0, 16]]

	if not InputManager.is_moving_x():
		return &"Idle"

	if Input.is_action_pressed(&"crouch"):
		if movement.is_slide_slope():
			return &"ButtSlide"

		return [&"Crouch", [false, true]]

	if InputManager.get_x_dir() != 0 and actor.is_on_wall():
		if actor.push_rays.is_colliding():
			return &"Push"

		return &"DryPush"

	return &""
