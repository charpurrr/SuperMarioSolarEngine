class_name Hit
extends PlayerState
## Getting hit and taking damage.

@export var camera_shake_power: int = 6

## How long the game freezes after you get hit.
@export var freeze_time: int = 10
var freeze_timer: int


func _on_enter(_param: Variant) -> void:
	actor.velocity = Vector2.ZERO
	freeze_timer = freeze_time

	Engine.time_scale = 0.01
	await get_tree().create_timer(
		freeze_time / Engine.get_frames_per_second(),
		true,
		false,
		true
		).timeout
	Engine.time_scale = 1.0

	actor.camera.shake(Math.random_coord(camera_shake_power))
	actor.health_module.enabled = false


func _physics_tick(_delta: float) -> void:
	freeze_timer = max(freeze_timer - 1, 0)


func _trans_rules() -> Variant:
	if freeze_timer == 0:
		actor.health_module.enabled = true
		return &"Airborne"

	return &""
