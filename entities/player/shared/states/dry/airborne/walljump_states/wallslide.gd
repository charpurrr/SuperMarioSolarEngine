class_name Wallslide
extends PlayerState
## Holding the facing direction against a wall while airborne.

## How fast you can slide downwards during a wallslide.
@export var term_vel: float = 1.10
## How fast you accelerate to the terminal velocity.
@export var gravity_friction: float = 8.0


func _on_enter(_param):
	movement.consume_coyote_timer()
	movement.consec_jumps = 0


func _physics_tick(_delta: float):
	actor.velocity.y = min(actor.velocity.y, term_vel)
	# Vertical push force so the player stays on the wall.
	actor.velocity.x = movement.facing_direction


func _subsequent_ticks(delta: float):
	movement.apply_gravity(delta, 1, gravity_friction)

	var offset_hand := Vector2(
		particles[0].particle_offset.x * movement.facing_direction,
		particles[0].particle_offset.y
	)
	particles[0].emit_at(actor, offset_hand)

	var offset_foot := Vector2(
		particles[1].particle_offset.x * movement.facing_direction,
		particles[1].particle_offset.y
	)
	particles[1].emit_at(actor, offset_foot)

func _trans_rules():
	if input.buffered_input(&"spin"):
		return &"SpinWallbonk"

	if input.buffered_input(&"jump"):
		return [&"Walljump", -movement.facing_direction]

	if movement.should_end_wallslide():
		return &"Fall"

	if Input.is_action_just_pressed(&"groundpound") and movement.can_air_action():
		return &"GroundPound"

	return &""
