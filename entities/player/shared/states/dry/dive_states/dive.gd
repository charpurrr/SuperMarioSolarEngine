class_name Dive
extends PlayerState
## General diving state.

## The horizontal dive power added to your current velocity.
@export var x_power: float = 6.0
## The vertical power added to your velocity when performing a bellyflop.
@export var bellyflop_power: float = 3.0
## The minimum horizontal acceleration step.
@export var min_accel: float = 0.05
## The maximum horizontal acceleration step.
@export var max_accel: float = 0.2
## The maximum horizontal speed you need to reach before dives no longer
## contribute to your x velocity.
@export var speed_cap: float = 8.0


# dive_direction is an integer that defines the direction in which 
# the dive will initially send you.
func _on_enter(dive_direction):
	if dive_direction != null:
		movement.update_direction(dive_direction)

	movement.consume_coyote_timer()
	movement.consec_jumps = 0
	movement.dived = true

	actor.set_floor_snap_length(movement.snap_length)
	actor.dive_hurtbox.monitoring = true

	if actor.is_on_floor():
		actor.vel.y = -bellyflop_power

	if movement.facing_direction != sign(actor.vel.x):
		actor.vel.x = 0

	movement.accelerate(Vector2.RIGHT * movement.facing_direction * x_power, speed_cap)

	# Sprite rotation starts at 0 when neutral, 
	# which actually corresponds with 90° or PI / 2.
	# To get around this problem we use the 
	# opposite complement of the velocity angle:
	# (TAU / 4 - alpha)
	actor.doll.rotation = TAU / 4 + actor.vel.angle()


func _physics_tick():
	if not actor.is_on_floor():
		movement.body_rotation = TAU / 4 + actor.vel.angle()

	var speed_factor: float = min(1.0, inverse_lerp(0.0, speed_cap, abs(actor.vel.x)))
	var accel: float = lerp(min_accel, max_accel, speed_factor)

	movement.move_x_analog(accel, false)

	actor.doll.rotation = lerp_angle(actor.doll.rotation, movement.body_rotation, 0.5)


func _subsequent_ticks():
	movement.apply_gravity()


func _on_exit():
	movement.body_rotation = 0
	actor.doll.rotation = 0

	actor.dive_hurtbox.monitoring = false


func _trans_rules():
	if actor.is_on_floor():
		return &"DiveSlide"

	if actor.is_on_wall():
		return &"Bonk"

	if movement.can_air_action() and Input.is_action_just_pressed(&"groundpound"):
		return &"GroundPound"

	return &""


func _on_dive_hurt_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.health_module.damage(actor, HealthModule.DamageType.STRIKE, 1)
	elif body is Breakable:
		body.shatter()
