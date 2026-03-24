class_name PMovement
extends Node
## Movement for player characters.

@export var actor: Player

#region X Variables
@export_category("X Variables")

## Max horizontal speed.
@export var max_speed: float = 2.8

## The minimum velocity required to enter a [Skid] state.
@export var min_skid_vel: float = 60.0

## How long it takes to accelerate when grounded.
@export var ground_accel_time: float = 22.5
@onready var ground_accel_step: float = max_speed / ground_accel_time

## How long it takes to decelerate when grounded.
@export var ground_decel_time: float = 13.5
@onready var ground_decel_step: float = max_speed / ground_decel_time

## How long it takes to accelerate when airborne.
@export var air_accel_time: float = 20.0
@onready var air_accel_step: float = max_speed / air_accel_time

## How long it takes to decelerate when airborne.
@export var air_decel_time: float = 18.0
@onready var air_decel_step: float = max_speed / air_decel_time

## How many frames have to progress before you can accelerate forward again.
@export var return_time: int = 15
var return_timer: float
#endregion

#region Y Variables
@export_category("Y Variables")

## Max vertical speed.
@export var term_vel: float = 6.60

## How low gravity can interpolate.
@export var min_grav: float = max_grav
## How high gravity can interpolate.
@export var max_grav: float = 0.22

## Amount of units the player needs to be above the ground to perform an airborne action.
@export var air_margin: int = 10


## The y position of the point you walljumped from.
## Used to avoid being able to scale a wall infinitely.
var walljump_start_y: float
## How many units you need to pass from your original walljump y position
## in order to be turned around. See 'walljump_start_y'.
## Defaulted to roughly the amount of height you can get from a spin.
@export var walljump_turn_threshold: float = 10.0
#endregion

#region Swimming Variables
@export_category("Swimming Variables")

## The normal maximum swimming speed.[br][br]
## (Abnormal swimming speed would come from manual velocity overrides.)
@export var swim_speed: float = 4.0

@export var swim_accel_time: float = 15.0
@onready var swim_accel_step: float = swim_speed / float(swim_accel_time)
#endregion

#region Timer Variables
@export_category("Timer Variables")

## How many frames an airborne input is still registered after leaving the ground.
@export var coyote_time: int = 7
var coyote_timer: int

## How many frames can be between consecutive timed jump inputs. (Triple jump)
@export var consec_jump_time: int = 10
var consec_jump_timer: int

@export var ground_spin_cooldown_time: int = 20
var ground_spin_cooldown_timer: int

## How many frames need to pass before you start freefalling out of a normal fall.
@export var freefall_time: int = 100
var freefall_timer: int = -1
#endregion

#region Miscellaneous Variables
@export_category("Miscellaneous Variables")

## Minimum incline of slope (0.0 - 1.0) needed to start a buttslide.
@export_range(0.0, 1.0) var min_slide_incline: float = 0.3
## Minimum incline of slope (0.0 - 1.0) needed to be considered a steep slope.
## Steep slopes automatically make you slide off.
@export_range(0.0, 1.0) var min_steep_incline: float = 0.8

var facing_direction: int = 1
## facing_direction on the previous frame.
var prev_facing_direction: int

## Whether or not you've performed an airborne spin.
var air_spun: bool = false
## Whether or not you've performed a dive.
var dived: bool = false

## Amount of consecutive jumps performed for a triple jump.
var consec_jumps: int = 0

## The player body rotation in radians.
var body_rotation: float = 0
#endregion


func _physics_process(_delta):
	ground_spin_cooldown_timer = max(ground_spin_cooldown_timer - 1, 0)
	return_timer = max(return_timer - 1, 0)

	# Grounded
	if actor.is_on_floor():
		consec_jump_timer = max(consec_jump_timer - 1, -1)

		if consec_jump_timer == 0:
			consec_jumps = 0
	# Airborne
	else:
		coyote_timer = max(coyote_timer - 1, 0)

		# Rising
		if actor.velocity.y < 0:
			consume_coyote_timer()
		# Falling
		elif actor.velocity.y > 0:
			freefall_timer = max(freefall_timer - 1, -1)


#region X Functions
## Accelerate by a given velocity, up to a certain limit.
## If already above the limit due to external forces, this will not reduce speed.
## If [param angular_friction] is greater than [code]0[/code], the cap will be applied in all directions.
## Attempting to accelerate perpendicular to the currend direction of motion while over the cap
## will decelerate in the previous direction in order to avoid accelerating overall.
func accelerate(add_vel: Vector2, cap: float, angular_friction: float = 0) -> void:
	# Normalising a zero vector will result in unexpected behavior
	if add_vel.is_zero_approx():
		return

	var direction = add_vel.normalized()
	
	var speed = actor.velocity.dot(direction)
	var speed_step = add_vel.length()

	# How much speed allowed to be add before getting capped
	var cap_difference = cap - speed

	speed_step = min(speed_step, cap_difference)

	# Break if less than zero to avoid deceleration
	speed_step = max(speed_step, 0)
	
	# Apply the speed in the correct direction
	var speed_step_vec: Vector2 = speed_step * direction

	var target_vel: Vector2 = actor.velocity + speed_step_vec

	if angular_friction > 0:
		var target_speed: float = target_vel.length()
		var current_absolute_difference: float = min(cap - actor.velocity.length(), 0)
		var target_absolute_difference: float = cap - target_vel.length()
		var speed_overshoot: float = min(target_absolute_difference - current_absolute_difference, 0)

		target_vel = target_vel.limit_length(target_speed + speed_overshoot)

		var perp = target_vel.slide(direction)
		var perp_len_reduced = max(perp.length() - add_vel.length() * angular_friction, 0)

		target_vel = perp.limit_length(perp_len_reduced) + target_vel.project(direction)

	actor.velocity = target_vel


## Decelerate by a given velocity.
## The sign of the vector does not matter - will always decelerate towards zero.
func decelerate(sub_vel: Vector2):
	# Normalising a zero vector will result in unexpected behavior
	if sub_vel.is_zero_approx():
		return

	var direction = sub_vel.normalized()
	var speed = actor.velocity.dot(direction)
	var speed_step = sub_vel.length()

	actor.velocity = move_toward(speed, 0, speed_step) * direction + actor.velocity.slide(direction)


## Force friction when above a certain threshold.
func radial_friction(friction: float, threshold: float) -> void:
	var speed = actor.velocity.length()

	if speed > threshold:
		speed = move_toward(speed, threshold, friction)

	actor.velocity = actor.velocity.limit_length(speed)


## Handles movement on the X axis.
func move_x(accel_val: float, should_flip: bool, speed_cap: float = max_speed):
	var input: int = InputManager.get_x_dir()

	if should_flip:
		update_direction(input)

	accelerate(accel_val * Vector2.RIGHT * input, speed_cap)


## Handles movement on the X axis for joystick analog inputs.
func move_x_analog(
	accel_val: Variant, should_flip: bool, friction_val: Variant = 0.0, speed_cap: float = max_speed
):
	var input: float = InputManager.get_x()

	var normalised_input: float = sign(input)
	var analog_input: float = abs(input)

	if should_flip:
		update_direction(int(normalised_input))

	accelerate(accel_val * Vector2.RIGHT * input, speed_cap * analog_input)

	if abs(actor.velocity.x) > speed_cap * analog_input:
		decelerate(friction_val * Vector2.RIGHT)


## Updates the player's visual facing direction.
func update_direction(direction: int):
	var new_direction = sign(direction)

	if new_direction == 0:
		return

	if facing_direction != new_direction:
		actor.doll.offset.x = -actor.doll.offset.x

	facing_direction = new_direction

	var flip_sprites: bool = (facing_direction == -1)
	actor.doll.flip_h = flip_sprites
	actor.fludd_b.flip_h = flip_sprites
	actor.fludd_f.flip_h = flip_sprites


func update_prev_direction():
	prev_facing_direction = facing_direction


## Checks if the space at a position can be moved into.
func check_accessible_space(delta: Vector2) -> bool:
	var collision := KinematicCollision2D.new()

	if actor.test_move(actor.transform, delta, collision):
		return collision.get_normal().dot(Vector2.UP) > 0.5
	else:
		return true


## Check if there is accessible space in front of the player.
func check_space_ahead() -> bool:
	return check_accessible_space(Vector2(facing_direction, 0))


func get_input_x() -> float:
	return roundf(Input.get_axis("left", "right"))


#endregion


#region Y Functions
func apply_gravity(delta:float, gravity_weight: float = 1, friction: float = 1):
	var gravity = lerpf(min_grav, max_grav, gravity_weight) / friction

	if actor.velocity.y + gravity * delta < term_vel:
		actor.velocity.y += gravity * delta
	elif actor.velocity.y < term_vel:
		actor.velocity.y = term_vel


#endregion


#region Timer Functions
## Activate the consecutive jump timer.
func activate_consec_timer() -> void:
	consec_jump_timer = consec_jump_time


## Return whether the consecutive jump timer is or isn't running.
func active_consec_time() -> bool:
	return consec_jump_timer > 0


## Consume the consecutive jump timer, ridding of any chance at a consecutive jump.
func consume_consec_timer() -> void:
	consec_jump_timer = -1


## Activate the coyote timer.
func activate_coyote_timer() -> void:
	coyote_timer = coyote_time


## Return whether the coyote timer is or isn't running.
func active_coyote_time() -> bool:
	return coyote_timer > 0


## Consume the coyote timer, ridding of any chance at a coyote input.
func consume_coyote_timer() -> void:
	coyote_timer = 0


## Activate the freefall timer.
func activate_freefall_timer() -> void:
	freefall_timer = freefall_time


## Return whether the freefall timer has finished or not.
func finished_freefall_timer() -> bool:
	return freefall_timer == 0


## Consume the freefall timer, ridding of any chance at freefalling.
func consume_freefall_timer() -> void:
	freefall_timer = -1


## Activate the grounded spin cooldown timer.
func activate_grounded_spin_timer() -> void:
	ground_spin_cooldown_timer = ground_spin_cooldown_time


## Return whether the grounded spin timer cooldown has finished or not.
func finished_grounded_spin_timer() -> bool:
	return ground_spin_cooldown_timer == 0


## Consume the grounded spin cooldown timer, making you able to perform a grounded spin immediately.
func consume_grounded_spin_timer() -> void:
	ground_spin_cooldown_timer = 0


#endregion


#region Check Functions
## Return the incline of the floor below you, from 0.0 to 1.0.
func get_floor_incline() -> float:
	return angle_difference(-TAU / 4.0, actor.get_floor_angle()) / (TAU / 4.0) - 1


## Check if the slope below the player is a slidable one.
## (A small value is substracted due to floating point precision errors.)
func is_slide_slope() -> bool:
	return get_floor_incline() > min_slide_incline - 0.01


## Check if the slope below the player is a steep one.
## (A small value is substracted due to floating point precision errors.)
func is_steep_slope() -> bool:
	return get_floor_incline() > min_steep_incline - 0.01


## Whether or not the jump can be variated (released).
func can_release_jump(applied_variation: bool, min_jump_power: float) -> bool:
	return (
		not Input.is_action_pressed(&"jump")
		and actor.velocity.y > -min_jump_power
		and not applied_variation
		and actor.velocity.y < 0
	)


## Return whether you can or can't initiate a wallslide.
## input_based is whether or not a wallslide prioritises input over facing_direction.
func can_init_wallslide(input_based: bool = false) -> bool:
	if should_end_wallslide(input_based):
		return false

	if not actor.velocity.y >= 0:
		return false

	return input_based or get_input_x() == facing_direction


## Return whether or not a wallslide should end.
func should_end_wallslide(input_based: bool = false) -> bool:
	if not actor.push_rays.is_colliding(input_based):
		return true
	if not input_based and get_input_x() == -facing_direction:
		return true
	if not can_air_action():
		return true

	return false


## Return whether or not you can perform a spin attack.
func can_spin() -> bool:
	return can_air_action() or finished_grounded_spin_timer()


## Return whether or not you can perform an airborne action.
## Avoids accidental air movement inputs.
func can_air_action() -> bool:
	var collision := KinematicCollision2D.new()
	actor.test_move(actor.transform, Vector2i(0, air_margin), collision)

	return collision.get_angle() > actor.floor_max_angle or actor.velocity.y < 0


func is_submerged() -> bool:
	return actor.water_check.has_overlapping_areas()
#endregion
