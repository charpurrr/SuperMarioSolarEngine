class_name ButtSlide
extends PlayerState
## Crouching while on a slope.

## See [member CharacterBody2D.floor_snap_length].
@export var floor_snap_length: float = 32.0
## The default frictional coefficient.
@export var friction_coefficient_default: float
## The frictional coefficient when over the maximum speed.
@export var friction_coefficient_overspeed: float
## The gravity multiplier when holding the direction you're sliding in.
@export var accel_gravity_multiplier: float

## How quickly you can slide when decelerating.
@export var max_speed_decel: float
## How quickly you can slide when not accelerating or decelerating.
@export var max_speed: float
## How quickly you can slide when accelerating.
@export var max_speed_accel: float

## How much speed the [Player] needs to remain in a sliding state.
@export var min_remain_speed: float

@export_category(&"Animation (Unique to State)")
## Animation used by default.
@export var default_animation_data: PStateAnimData
## Animation used when holding downhill.
@export var forward_animation_data: PStateAnimData
## Animation used when holding uphill.
@export var backward_animation_data: PStateAnimData
## Animation used when sliding off a ledge.
## Not to be confused with [ButtSlideJump].
@export var airborne_animation_data: PStateAnimData


func _on_enter(handover_speed):
	actor.set_floor_snap_length(floor_snap_length)

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

	var slide_accel: float
	var speed_limit: float
	var friction: float = friction_coefficient_default
	var overspeed_friction: float = friction_coefficient_overspeed

	match accel_dir:
		-1: # decelerating
			slide_accel = movement.max_grav
			speed_limit = max_speed_decel
		0: # not holding a direction
			slide_accel = movement.max_grav
			speed_limit = max_speed
		1: # accelerating
			slide_accel = movement.max_grav * accel_gravity_multiplier
			speed_limit = max_speed_accel

	# Apply gravity
	actor.velocity += Vector2.DOWN.slide(actor.get_floor_normal()) * slide_accel * delta

	# Calculate normal acceleration
	var normal_accel = Vector2.UP.dot(actor.get_floor_normal()) * slide_accel

	# Check if under the speed limit:
	if actor.velocity.length() <= speed_limit:
		# If yes, apply regular friction
		actor.velocity = actor.velocity.move_toward(Vector2.ZERO, friction * normal_accel * delta)
	else:
		# If no, apply overspeed friction. Speed should not go below the speed limit.
		actor.velocity = actor.velocity.move_toward(actor.velocity.limit_length(speed_limit), 
			overspeed_friction * normal_accel * delta)

	slide_sfx.unpause()


## Buttsliding in the air.
func _airborne(delta: float):
	movement.apply_gravity(delta)

	slide_sfx.pause()


## Set the animation based on how you're moving on a slope.
func _set_appropriate_anim():
	# Play airborne animation if not on floor
	if not actor.is_on_floor():
		overwrite_animation(airborne_animation_data)
		return

	var x_dir := InputManager.get_x_dir()

	# Play forwards animation when moving in the same direction as the slide
	if x_dir == movement.facing_direction:
		overwrite_animation(forward_animation_data)
	# Play backwards animation when moving in opposite direction as the slide
	elif x_dir == -movement.facing_direction:
		overwrite_animation(backward_animation_data)
	# Play normal slide animation
	else:
		overwrite_animation(default_animation_data)


func _on_exit() -> void:
	slide_sfx.stop()


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
