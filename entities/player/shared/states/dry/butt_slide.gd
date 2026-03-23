class_name ButtSlide
extends PlayerState
## Crouching while on a slope (or being forced.)

@export var friction_coefficient_default: float
@export var friction_coefficient_decel: float
@export var accel_gravity_multiplier: float
@export var max_speed: float
@export var min_remain_speed: float

@export_category(&"Animation (Unique to State)")
@export var animation_forward: StringName
@export var anim_offset_f: Vector2
@export var animation_backward: StringName
@export var anim_offset_b: Vector2
@export var animation_airborne: StringName
@export var anim_offset_a: Vector2


func _on_enter(handover_speed):
	# TODO: find out why this line is here. removing it causes some weird behaviour but idk why
	actor.set_floor_snap_length(movement.snap_length)
	
	# Convert vertical speed from ground pounding into sliding speed
	if handover_speed is float:
		actor.velocity = (Vector2.DOWN * handover_speed).slide(actor.get_floor_normal())


func _physics_tick(delta: float):
	# Apply physics
	if actor.is_on_floor():
		_grounded(delta)
	else:
		_airborne(delta)
	
	# Set animations
	_set_appropriate_anim()


func _subsequent_ticks(_delta: float):
	# Emit particles and play sound effects
	if actor.is_on_floor():
		particles[0].emit_at(actor)

		if not get_tree().has_group(name + "/sfx"):
			play_sounds()
	else:
		get_tree().call_group(name + "/sfx", &"queue_free")


## Buttsliding on the ground / slope.
func _grounded(delta: float):
	# Equal to 1 if accelerating, -1 if decelerating, 0 otherwise.
	var accel_dir: int = InputManager.get_x_dir() * sign(actor.velocity.x)
	# Coefficient of friction, should be increased when decelerating.
	var friction: float = friction_coefficient_decel if accel_dir == -1 else friction_coefficient_default
	# Acceleration due to sliding from gravity, should be increased when accelerating.
	var slide_accel: float = movement.max_grav
	if accel_dir == 1: slide_accel *= accel_gravity_multiplier
	
	# Apply gravity
	actor.velocity += Vector2.DOWN.slide(actor.get_floor_normal()) * slide_accel * delta
	
	# Calculate normal acceleration
	var normal_accel = Vector2.UP.dot(actor.get_floor_normal()) * slide_accel
	
	# Calculate frictional acceleration
	actor.velocity = actor.velocity.move_toward(Vector2.ZERO, friction * normal_accel * delta)
	
	# Cap the speed
	actor.velocity = actor.velocity.limit_length(max_speed)


## Buttsliding in the air.
func _airborne(delta: float):
	movement.apply_gravity(delta)


## Set the animation based on how you're moving on a slope.
func _set_appropriate_anim():
	# Play airborne animation if not on floor
	if not actor.is_on_floor():
		actor.doll.play(animation_airborne)
		return
	
	# Play moving forward/backward if left/right is held.
	if InputManager.get_x_dir() != 0:
		actor.doll.play(
			animation_forward if InputManager.get_x_dir() == movement.facing_direction else animation_backward
		)
		return
	
	# Play default animation otherwise.
	actor.doll.play(animation_data.animation)


func _trans_rules():
	# When slow enough on flat ground, exit the sliding state.
	if not movement.is_slide_slope() and abs(actor.velocity.x) < min_remain_speed:
		if Input.is_action_pressed(&"down"):
			return [&"Crouch", [true, false]]
		else:
			return &"Idle"

	# Exit the sliding state when up is pressed.
	if input.buffered_input(&"up"):
		if actor.is_on_floor():
			return &"Idle"
		else:
			return &"Fall"

	# Jump out of a buttslide:
	if actor.is_on_floor() and input.buffered_input(&"jump"):
		return &"ButtSlideJump"

	# Spin out of a buttslide:
	if input.buffered_input(&"spin"):
		return &"Spin"

	return &""
