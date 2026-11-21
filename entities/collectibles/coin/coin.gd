@tool
class_name Coin
extends Collectible
## Base class for collectible coins.

@export var collect_sound: SoundEffect
@export var collect_particle: ParticleEffect


func _on_collect():
	var stage: Node2D = StageManager.stage

	collect_particle.emit_at(stage, position)

	collect_sound.position = global_position
	collect_sound.play(stage)

	queue_free()
