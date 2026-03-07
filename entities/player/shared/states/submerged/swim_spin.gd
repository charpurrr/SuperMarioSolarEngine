class_name SwimSpin
extends PlayerState
## Spinning underwater.

## Gets added on top of [member PMovement.swim_speed].
@export var extra_boost_speed: float


func _physics_tick(_delta: float):
	var boost_speed = movement.swim_speed + extra_boost_speed

	movement.accelerate(
		Vector2.from_angle(actor.doll.rotation) * boost_speed * movement.facing_direction,
		boost_speed,
		0.03125
	)

	movement.radial_friction(0.0625, boost_speed)


func _trans_rules():
	if not actor.doll.is_playing():
		return &"Swim"

	return &""
