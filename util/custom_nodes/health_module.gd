class_name HealthModule
extends RefCounted
## Provides a simple way to add health to entities.

signal damaged(hits: int, type: DamageType)

enum DamageType { SQUISH, STRIKE, BURN, FREEZE, SHOCK, GENERIC }

## How frequently the actor flashes when granted invincibility frames in frames.
const I_FRAME_FREQ: int = 3

var enabled: bool = true

var hp: int

var hit_callback: Callable
var die_callback: Callable



func _init(hit_points: int, hit_callback_pass: Callable, die_callback_pass: Callable):
	hp = hit_points

	hit_callback = hit_callback_pass
	die_callback = die_callback_pass

	if hp <= 0:
		push_warning("Object spawned with zero or less health, which caused immediate demise.")
		die_callback.call()


func grant_i_frames(actor: Node2D, count: int):
	var i_timer := count

	enabled = false

	while i_timer != 0:
		i_timer = max(i_timer - 1, 0)

		# Handle flashing
		@warning_ignore("integer_division")
		if (i_timer / I_FRAME_FREQ) % 2 == 0:
			actor.doll.self_modulate = Color.TRANSPARENT
		else:
			actor.doll.self_modulate = Color.WHITE

		await actor.get_tree().process_frame

	actor.doll.self_modulate = Color.WHITE
	enabled = true


func damage(source: Node, damage_type: DamageType, damage_points: float = 1.0, bypass: bool = false):
	if not enabled and not bypass:
		return

	hp = max(hp - damage_points, 0)

	damaged.emit(damage_points, damage_type)

	if hp != 0:
		hit_callback.call(source, damage_type)
	else:
		die_callback.call(source, damage_type)
