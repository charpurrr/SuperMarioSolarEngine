class_name Skid
extends PlayerState
## Turning around.

## How long it takes to accelerate from a skid.
@export var skid_accel_time: float = 16
@onready var skid_accel_step: float

## How much the skid should accelerate over max_speed.
@export var over_accel: float = 0.3

var accel_val: Vector2


# The first entry in the array is what frame the animation should skip to,
# the second entry is how long it should take to accelerate.
func _on_enter(array):
	movement.update_direction(-movement.facing_direction)

	actor.doll.frame = array[0]
	actor.velocity.x = 0

	skid_accel_step = (movement.max_speed + over_accel) / array[1]


func _physics_tick(_delta: float):
	accel_val = Vector2.RIGHT * skid_accel_step * movement.facing_direction
	movement.accelerate(accel_val, INF)


func _trans_rules():
	if not InputManager.is_moving_x() or actor.velocity.x == 0 or actor.is_on_wall():
		return &"Idle"

	if InputManager.get_x_dir() == -movement.facing_direction:
		reset_state([0, 16])

	if abs(actor.velocity.x) > movement.max_speed + over_accel:
		return &"Walk"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"Sideflip"

	if Input.is_action_pressed(&"crouch"):
		return [&"Crouch", [false, true]]

	if input.buffered_input(&"dive"):
		return &"Dive"

	return &""
