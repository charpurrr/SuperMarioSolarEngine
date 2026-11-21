@tool
class_name Shine
extends Collectible
## Collectible Shine Sprites.

@export var shine_name: StringName
@export_multiline var description: String

@export var particle: ParticleEffect


func _process(_delta: float) -> void:
	particle.emit_at(self)


func _on_collect() -> void:
	StageManager.player.state_manager.set_to_state(&"Fall")
	queue_free()
