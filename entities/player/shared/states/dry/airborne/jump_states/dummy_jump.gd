class_name DummyJump
extends PlayerState
## General jump action.

## Minimum X velocity required to perform the third consecutive jump.
@export var triple_min_vel: float = 1.0


func _on_enter(_param):
	movement.consume_coyote_timer()


func _defer_rules():
	if not movement.active_consec_time():
		return &"Jump"

	match movement.consec_jumps:
		2:
			if (abs(actor.velocity.x) > triple_min_vel and
			sign(actor.velocity.x) == movement.facing_direction):
				return &"TripleJump"
			else:
				return &"DoubleJump"
		1:
			return &"DoubleJump"
		_:
			return &"Jump"
