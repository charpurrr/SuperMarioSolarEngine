class_name ButtSlide
extends PlayerState
## Crouching while on a slope (or being forced.)

## Default sliding speed.
@export var speed: float = 10
## Minimum sliding speed (through decelerating by holding the opposite direction you're sliding in.)
@export var min_speed: float = 5
## Maximum sliding speed (through accelerating by holding the direction you're sliding in.)
@export var max_speed: float = 20
## Minimum sliding speed necessary to remain in a buttslide state.
## (In practice: how much you'll be sliding on flat ground after sliding off a slope.)
@export var min_remain_speed: float = 0.1

## Friction applied when sliding along flat or shallow ground.
@export var friction: float = 0.125

## Maximum acceleration from sliding, when a slope is as steep as possible.
@export var max_accel: float = 0.22

## How much speed is lost when changing slope angle.
## Higher turn forgiveness means more speed is lost.
@export_exp_easing() var turn_forgiveness: float = 2.0

## Higher shallowness penalty means shallow slopes will decrease speed more.
@export_exp_easing() var shallow_penalty: float = 0.5
## Higher friction means less speed conservation on steep slopes.
@export_exp_easing() var incline_friction: float = 10.0

@export_category(&"Animation (Unique to State)")
@export var animation_forward: StringName
@export var anim_offset_f: Vector2
@export var animation_backward: StringName
@export var anim_offset_b: Vector2
@export var animation_airborne: StringName
@export var anim_offset_a: Vector2

## Speed at which the player slides.
var slide_speed: float = 0.0

## Stored previous direction, for changing slope angle.
var old_direction: Vector2

## True when the player does not have a slide direction yet.
var no_direction: bool

var input_dir: int


func _on_enter(handover_speed):
	actor.set_floor_snap_length(movement.snap_length)

	if handover_speed is float:
		old_direction = Vector2.DOWN
		slide_speed = handover_speed
	else:
		no_direction = true
		slide_speed = 0


func _physics_tick(_delta: float):
	if actor.is_on_floor():
		_grounded()
	else:
		_airborne()

	_set_appropriate_anim()


func _subsequent_ticks():
	if actor.is_on_floor():
		particles[0].emit_at(actor)

		if not get_tree().has_group(name + "/sfx"):
			play_sounds()
	else:
		get_tree().call_group(name + "/sfx", &"queue_free")


## Buttsliding on the ground / slope.
func _grounded():
	var floor_normal: Vector2 = actor.get_floor_normal()

	var slide_direction: Vector2

	slide_direction = _get_slide_dir(floor_normal)
	input_dir = InputManager.get_x_dir()

	if no_direction:
		_apply_slide_direction(floor_normal, slide_direction)
	else:
		# If we're changing direction, redirect current sliding speed into the new direction
		if not slide_direction.is_equal_approx(old_direction):
			_redirect_slide(slide_direction, old_direction)

	# Modify slide_speed prior to setting velocity
	_modify_speed(floor_normal)

	actor.velocity = slide_direction * slide_speed
	actor.velocity.y += 6.0

	# Store the sliding direction so we can check for changes
	old_direction = slide_direction


## Buttsliding in the air.
func _airborne():
	no_direction = true
	slide_speed = 0

	movement.apply_gravity()


## Get the slide direction downwards along the slope.
func _get_slide_dir(floor_normal: Vector2) -> Vector2:
	var direction: Vector2

	if floor_normal == Vector2.UP:
		# On flat ground, just go right.
		direction = Vector2.RIGHT
	else:
		direction = floor_normal.orthogonal()

		if direction.dot(Vector2.DOWN) < 0:
			direction = -direction

	return direction


## Integrate current velocity and direction to a slide.
func _apply_slide_direction(floor_normal: Vector2, slide_direction: Vector2):
	# If we have only just started sliding,
	# we need to convert the player's velocity into sliding speed.
	if floor_normal == Vector2.UP:
		slide_speed = actor.velocity.x
	else:
		if abs(actor.velocity.x) > abs(actor.velocity.dot(slide_direction)):
			slide_speed = actor.velocity.x * sign(floor_normal.x)
		else:
			slide_speed = actor.velocity.dot(slide_direction)

	no_direction = false


## Calculates acceleration, deceleration, and target speed; then applies them.
func _modify_speed(floor_normal: Vector2):
	# How flat the floor is, 0-1
	var flatness: float = floor_normal.dot(Vector2.UP)
	# How steep the floor is (opposite of flatness, just for convenience)
	var steepness: float = 1 - flatness
	var slope_dir: int = sign(floor_normal.x)

	var accel_ease: float = ease(steepness, shallow_penalty)

	var slide_accel: float = accel_ease * max_accel
	var slide_decel: float = ease(flatness, incline_friction) * friction

	var target_speed: float = accel_ease * speed

	if input_dir != 0:
		# Holding the direction of the slope (accel)
		if input_dir == slope_dir:
			target_speed = accel_ease * max_speed
		# Holding the opposite direction of the slope (decel)
		elif input_dir == -slope_dir:
			target_speed = accel_ease * min_speed
		
	slide_decel = max(slide_decel, 6.0)

	# Accelerate down the slope
	_accelerate(slide_accel, target_speed)
	# Decelerate due to friction
	_decelerate(slide_decel, target_speed)


func _redirect_slide(new: Vector2, old: Vector2):
	# Calculate how similar the new direction is to the old direction
	var preserved = new.dot(old)

	# Store the sign: -1 if we have moved from an upward slope to a downward slope
	# or vice versa
	var new_sign = sign(preserved)

	# Take absolute value so we can work with 0 to 1 instead of -1 to 1
	preserved = abs(preserved)

	# Calculate how much speed would be lost
	var lost = 1 - preserved
	# Apply forgiveness to what was lost
	var lost_forgiven = ease(lost, turn_forgiveness)

	# Subtract the reduced loss from 1
	var final_preserved = 1 - lost_forgiven

	slide_speed *= final_preserved * new_sign


func _accelerate(amount: Variant, speed_cap: float):
	if slide_speed + amount < speed_cap:
		slide_speed += amount
	elif slide_speed < speed_cap:
		slide_speed = speed_cap


func _decelerate(amount: float, target: float):
	var direction = sign(slide_speed)
	var abs_speed = abs(slide_speed)

	if abs_speed > target:
		abs_speed = max(abs_speed - amount, target)

	slide_speed = abs_speed * direction


## Set the animation based on how you're moving on a slope.
func _set_appropriate_anim():
	if not actor.is_on_floor():
		actor.doll.play(animation_airborne)
		return
	if input_dir != 0:
		actor.doll.play(
			animation_forward if input_dir == movement.facing_direction else animation_backward
		)
		return
	actor.doll.play(animation_data.animation)


func _trans_rules():
	if not movement.is_slide_slope() and abs(actor.velocity.x) < min_remain_speed:
		return [&"Crouch", [true, false]]

	if not Input.is_action_pressed(&"down"):
		if actor.is_on_floor():
			if old_direction.y == 0 and input_dir != 0 or Input.is_action_just_pressed(&"up"):
				return &"Idle"
			if input_dir == -sign(old_direction.x):
				return &"Walk"
		else:
			return &"Fall"

	if actor.is_on_floor() and input.buffered_input(&"jump"):
		return &"ButtSlideJump"

	if input.buffered_input(&"spin"):
		return &"Spin"

	return &""
