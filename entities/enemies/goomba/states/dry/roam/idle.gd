@tool
class_name GoombaIdle
extends EnemyState
## Standing idle, waiting for the player.

## How fast the Goomba decelerates from any momentum it had before going idle.
@export var decel: float = 0.1

## The minimum amount of time (in frames) the Goomba remains idle.
@export var min_wait_time: int = 100:
	set(val):
		min_wait_time = min(max_wait_time, val)
## The maximum amount of time (in frames) the Goomba remains idle.
@export var max_wait_time: int = 200:
	set(val):
		max_wait_time = max(min_wait_time, val)

var wait_timer: int = 0


func _on_enter(_param: Variant) -> void:
	wait_timer = randi_range(min_wait_time, max_wait_time)


func _physics_tick() -> void:
	actor.vel.x = move_toward(actor.vel.x, 0, decel)
	wait_timer = max(wait_timer - 1, 0)


func _trans_rules() -> Variant:
	if actor.is_on_wall():
		return [&"Walk", actor.get_wall_normal().x]

	if not actor.stationary and wait_timer == 0:
		return &"Walk"

	return &""
