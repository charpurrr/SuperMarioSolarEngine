class_name Hit
extends PlayerState
## Getting hit and taking damage.

@export var camera_shake_power: int = 6

## How long the game freezes after you get hit.
@export var freeze_time: int = 10
var freeze_timer: int


func _on_enter(_param: Variant) -> void:
	actor.vel = Vector2.ZERO
	freeze_timer = freeze_time

	actor.camera.shake(Math.random_coord(camera_shake_power))
	actor.health_module.enabled = false


func _physics_tick() -> void:
	freeze_timer = max(freeze_timer - 1, 0)


func _trans_rules() -> Variant:
	if freeze_timer == 0:
		return &"Airborne"

	return &""
