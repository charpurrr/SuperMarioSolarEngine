class_name SuperDiveRollout
extends DiveRollout
## Action based off of Legacy Super Mario 127's Super Dive Recover speedrun tech.
## Activated by diving and rolling out at the same time.

## Number of sparkle particles that'll appear.
const PARTICLE_AMT: int = 5
var particle_counter: int

## The horizontal dive power added to your current velocity.
@export var x_power: float = 6.0
## The maximum horizontal speed you need to reach before dives no longer
## contribute to your x velocity.
@export var speed_cap: float = 8.0


func _on_enter(_param):
	super(_param)

	movement.accelerate(Vector2.RIGHT * movement.facing_direction * x_power, speed_cap)

	actor.dive_hurtbox.monitoring = true

	particle_counter = PARTICLE_AMT


func _on_exit() -> void:
	super()

	actor.dive_hurtbox.monitoring = false


func _subsequent_ticks():
	super()

	if particle_counter > 0:
		particles[1].emit_at(actor)
		particle_counter = max(particle_counter - 1, 0)


func _trans_rules():
	if (
		not movement.dived
		and movement.can_air_action()
		and actor.vel.y > 0
		and (input.buffered_input(&"dive") or Input.is_action_pressed(&"dive"))
	):
		return &"Dive"

	if actor.is_on_floor():
		return &"Idle"

	if actor.is_on_wall():
		return &"Bonk"

	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	return &""
