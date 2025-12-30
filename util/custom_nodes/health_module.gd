class_name HealthModule
extends RefCounted
## Provides a simple way to add health to entities.

signal damaged(hits: int, type: DamageType)

var enabled: bool = true

var hp: int

var hit_callback: Callable
var die_callback: Callable

enum DamageType { SQUISH, STRIKE, BURN, FREEZE, SHOCK, GENERIC }


func _init(hit_points: int, hit_callback_pass: Callable, die_callback_pass: Callable):
	hp = hit_points

	hit_callback = hit_callback_pass
	die_callback = die_callback_pass

	if hp <= 0:
		push_warning("Object spawned with zero or less health, which caused immediate demise.")
		die_callback.call()


func damage(source: Node, damage_type: DamageType, damage_points: float = 1.0):
	if not enabled:
		return

	hp = max(hp - damage_points, 0)

	damaged.emit(damage_points, damage_type)

	if hp != 0:
		hit_callback.call(source, damage_type)
	else:
		die_callback.call(source, damage_type)
