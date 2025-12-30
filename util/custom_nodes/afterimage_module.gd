class_name AfterimageModule
extends Node

@export var enabled: bool = false:
	set(val):
		enabled = val

		if val == true:
			afterimage_timer = afterimage_cooldown

@export var actor: Node2D

@export_group("Afterimage", "afterimage")
@export var afterimage_color: Color
## How fast the afterimage effect displays (in frames.)
@export var afterimage_cooldown: int = 5
var afterimage_timer: int

## The offset at which the afterimage effect shows up.[br][br]
## [b]Note that:[/b][br]
## -    [constant Vector2.ZERO] is the player's world origin point.[br]
## -    The X- and or Y-coordinate gets inversed if the actor's doll is flipped.[br]
## (See [member Sprite2D.flip_h] and [member Sprite2D.flip_v].)
@export var afterimage_offset: Vector2
@export var afterimage_particle: ParticleEffect


func _process(_delta: float) -> void:
	if not enabled:
		return

	afterimage_timer = max(afterimage_timer - 1, 0)

	if afterimage_timer == 0:
		afterimage_timer = afterimage_cooldown

		var offset := Vector2(
			afterimage_offset.x * (-1 if actor.doll.flip_h else 1),
			afterimage_offset.y * (-1 if actor.doll.flip_v else 1)
			)

		var afterimage = afterimage_particle.emit_at(actor, offset)
		afterimage.doll = actor.doll
		afterimage.trail_color = afterimage_color
