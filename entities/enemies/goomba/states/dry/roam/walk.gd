@tool
class_name GoombaWalk
extends EnemyState
## Roaming around, looking for the player.

## The minimum amount of time (in frames) the Goomba walks for.
@export var min_walk_time: int = 100:
	set(val):
		min_walk_time = min(max_walk_time, val)
## The maximum amount of time (in frames) the Goomba walks for.
@export var max_walk_time: int = 200:
	set(val):
		max_walk_time = max(min_walk_time, val)

@export var walk_speed: float = 4.0

var walk_timer: int = 0
## What direction the walk will go in.
var walk_direction: int

var anim_frame_count: int = -1


func _on_enter(force_walk_dir: Variant) -> void:
	if anim_frame_count == -1:
		anim_frame_count = actor.doll.sprite_frames.get_frame_count(animation)

	walk_timer = randi_range(min_walk_time, max_walk_time)

	if force_walk_dir != null:
		walk_direction = roundi(force_walk_dir)
		actor.doll.flip_h = true if force_walk_dir == 1 else false
	else:
		var flip: bool = randi_range(0, 1)
		walk_direction = -1 if flip else 1
		actor.doll.flip_h = !flip


func _physics_tick() -> void:
	walk_timer = max(walk_timer - 1, 0)
	actor.vel.x = walk_speed * walk_direction


func _subsequent_ticks() -> void:
	# Don't walk into walls. (Life advice!)
	if actor.is_on_wall():
		reset_state(-walk_direction)

	if not actor.ledge_ray_l.is_colliding():
		reset_state(1)
	if not actor.ledge_ray_r.is_colliding():
		reset_state(-1)


func _trans_rules() -> Variant:
	if walk_timer == 0 and actor.doll.frame == anim_frame_count - 1:
		return &"Idle"

	return &""
