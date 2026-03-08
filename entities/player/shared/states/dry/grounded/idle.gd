class_name Idle
extends PlayerState
## Default grounded state when there is no input.

@export var idle_animation_data: PStateAnimData
@export var lookup_animation_data: PStateAnimData
@export var low_health_animation_data: PStateAnimData
## The sound effects that can play when on low health.
@export var low_health_sfx: SFXLayer
## At which frames of the low health animation,
## a sound effect from [member low_health_sfx] plays.
@export var low_health_frames: Array[int]

var current_frame: int
var last_frame: int


func _physics_tick(_delta: float):
	movement.update_prev_direction()
	movement.decelerate(movement.ground_decel_step * Vector2.RIGHT)

	current_frame = actor.doll.get_frame()

	if Input.is_action_pressed(&"up"):
		overwrite_animation(lookup_animation_data)
	elif actor.health_module.hp == 1:
		overwrite_animation(low_health_animation_data)

		if current_frame != last_frame:
			for frame in low_health_frames:
				if frame == current_frame:
					low_health_sfx.play_sfx_at(self)

	else:
		overwrite_animation(idle_animation_data)

	last_frame = current_frame


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
