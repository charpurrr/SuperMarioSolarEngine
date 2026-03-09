class_name Stomp
extends PlayerState
## Stomping on an enemy.

@export var accel: float = 20.0

@export var bounce_time: int = 20
var bounce_timer: int


func _on_enter(_param):
	bounce_timer = bounce_time


func _physics_tick(delta: float):
	movement.apply_gravity(delta)
	movement.move_x_analog(accel, true)

	bounce_timer = max(bounce_timer - 1, 0)


func _trans_rules() -> Variant:
	if bounce_timer == 0:
		pass

	return &""
