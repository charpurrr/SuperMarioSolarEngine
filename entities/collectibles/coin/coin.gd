@tool
class_name Coin
extends Collectible
## Base class for collectible coins.


enum Type {
	YELLOW = 0, ## Common yellow coin, adds +1 to the coin counter.
	BLUE = 1, ## Uncommon blue coin, adds +5 to the coin counter.
	RED = 2, ## One of the level's red coins. Collect all of them to spawn a Shine Sprite.
}

## Total red coin count in a level.
static var total_reds: int = 0

@export var type: Type:
	set(val):
		type = val
		play(str(type))

@export var respective_sounds: Dictionary[Type, SoundEffect]
@export var last_red_sound: SoundEffect
@export var respective_particles: Dictionary[Type, ParticleEffect]


func _ready() -> void:
	super()

	play(str(type))

	if type == Type.RED:
		add_to_group(&"red_coins")
		total_reds += 1


func _on_collect():
	get_tree().emit_signal(&"coin_collected", type)

	var parent: Node = get_parent()

	respective_particles[type].emit_at(parent, position)

	if type == Type.RED:
		var remaining_reds: int = get_tree().get_nodes_in_group(&"red_coins").size()

		if remaining_reds == 1:
			last_red_sound.position = global_position
			last_red_sound.play(parent)
		else:
			var sfx: SoundEffect = respective_sounds[type]
			var pitch: float = Math.map(remaining_reds, 2, total_reds, 1.5, 1.0)
			sfx.pitch = pitch
			sfx.position = global_position
			sfx.play(parent)
	else:
		var sfx: SoundEffect = respective_sounds[type]
		sfx.position = global_position
		sfx.play(parent)

	queue_free()
