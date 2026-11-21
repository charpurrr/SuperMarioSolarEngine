@tool
class_name RedCoin
extends Coin
## Incremental red coin that spawn a [Shine] when all of them are collected.

@export var last_coin_sound: SoundEffect


func _on_collect():
	var stage: Node2D = StageManager.stage

	collect_particle.emit_at(stage, position)

	var remaining_reds: int = StageCache.stage.total(&"red_coins") - StageCache.count(&"red_coins")

	if remaining_reds == 0:
		last_coin_sound.position = global_position
		last_coin_sound.play(stage)
	else:
		var pitch: float = remap(remaining_reds, 2, StageCache.stage.total(&"red_coins"), 1.5, 1.0)
		collect_sound.pitch = pitch
		collect_sound.position = global_position
		collect_sound.play(stage)

	queue_free()
