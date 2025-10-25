class_name GoombaDie
extends EnemyState
## Dying due to unfortunate circumstances.

@export var strike_x_power: float = 2
@export var strike_y_power: float = 4

## What kind of death is happening.
var death_type: HealthModule.DamageType

## Whether or not the Goomba should die when ready.
var ready_to_perish: bool = false:
	set(val):
		ready_to_perish = val

		if val == true:
			actor.queue_free()


func _physics_tick() -> void:
	# Special death requirements
	if death_type == HealthModule.DamageType.STRIKE:
		actor.vel.y += actor.gravity
		ready_to_perish = actor.is_on_floor() and actor.vel.y >= 0


# The first entry in the array is where the damage came from,
# the second entry is what type of damage was received.
func _on_enter(array) -> void:
	var source := array[0] as Node
	var damage_type := array[1] as HealthModule.DamageType

	death_type = damage_type

	match damage_type:
		HealthModule.DamageType.STRIKE:
			actor.vel.x = source.vel.x - sign(source.position.x - actor.position.x) * strike_x_power
			actor.vel.y = -strike_y_power
			actor.anime.play(&"die_strike")

		HealthModule.DamageType.SQUISH:
			actor.doll.animation = &"squish"
			actor.anime.play(&"die_squish")
			actor.anime.animation_finished.connect(func(_anim_name: StringName): ready_to_perish = true)


func _trans_rules() -> Variant:
	return &""
