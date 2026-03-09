class_name Die
extends PlayerState
## Dying due to unfortunate circumstances.

## How hard the player gets thrown when dying.
@export var throw_power: float = 100
## How hard the player rotates when dying.
@export var rotate_power: float = 5.0
## How long the player dies in frames.
@export var death_time: int = 100
var death_timer: int


func _on_enter(_param: Variant) -> void:
	actor.z_index += 1

	var throw_direction = Vector2(randf_range(-0.5, 0.5), -1).normalized()
	actor.velocity = throw_direction * throw_power

	death_timer = death_time


func _physics_tick(delta: float) -> void:
	movement.apply_gravity(delta)
	actor.doll.rotation += rotate_power * delta

	death_timer = max(death_timer - 1, 0)


func _on_exit() -> void:
	actor.world_machine.reload_level(SceneTransition.Type.BOWSER)


func _trans_rules() -> Variant:
	if death_timer == 0:
		return &"Airborne"

	return &""
