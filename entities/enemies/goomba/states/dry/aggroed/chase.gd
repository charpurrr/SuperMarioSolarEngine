class_name GoombaChase
extends EnemyState
## Chase after the player.

@export var chase_max_speed: float = 1.0
@export var chase_accel: float = 0.23

## How close the player needs to be in order for the Goomba to try
## catching them with a jump.
@export var range_jump := Vector2(10.0, 10.0)

## Direction the player is in, in relation to this Goomba.
var dir: int


func _physics_tick() -> void:
	if not actor.spotted_player:
		return

	actor.diff = actor.spotted_player.global_position - actor.global_position
	dir = sign(actor.diff.x)

	actor.vel.x = move_toward(actor.vel.x, chase_max_speed * dir, chase_accel)

	actor.doll.flip_h = true if dir == 1 else false
	actor.doll.speed_scale = actor.vel.x / chase_max_speed * 2


func _on_exit() -> void:
	actor.doll.speed_scale = 1


func _trans_rules() -> Variant:
	if not actor.spotted_player:
		return &""

	# Jump over gaps.
	if (
		not actor.ledge_ray_l.is_colliding() or
	 	not actor.ledge_ray_r.is_colliding()
	):
		return &"Jump"

	# Jump over obstacles.
	if (
		(actor.wall_ray_l.is_colliding() and dir == -1) or
		(actor.wall_ray_r.is_colliding() and dir == 1)
	):
		return &"Jump"

	# Try to catch the player by jumping underneath them.
	if (
		abs(actor.diff.x) <= range_jump.x and
		actor.diff.y <= range_jump.y and
		actor.spotted_player.is_on_floor()
	):
		return &"Jump"

	return &""
