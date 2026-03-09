class_name GoombaDie
extends EnemyState
## Dying due to unfortunate circumstances.

@export var strike_x_power: float = 2
@export var strike_y_power: float = 4

@export var stomp_sfx: AudioStream

@export var explode_pfx: ParticleEffect
@export var explode_sfx: AudioStream

## What kind of death is happening.
var death_type: HealthModule.DamageType

## Whether or not the Goomba should die when ready.
var ready_to_perish: bool = false:
	set(val):
		ready_to_perish = val

		if val == true and not begun_perish:
			actor.doll.visible = false

			var pfx: Node2D = explode_pfx.emit_at(actor)
			# The second child "ExplosionSmall" takes the longest out of the two.
			pfx.get_child(1).finished.connect(actor.queue_free)
			SFX.play_sfx(explode_sfx, &"Motion", self)

			begun_perish = true

var begun_perish: bool = false


func _physics_tick(delta: float) -> void:
	# Special death requirements
	if death_type == HealthModule.DamageType.STRIKE:
		actor.velocity.y += actor.gravity * delta

		if actor.is_on_floor() and actor.velocity.y >= 0:
			ready_to_perish = true


# The first entry in the array is where the damage came from,
# the second entry is what type of damage was received.
func _on_enter(array) -> void:
	var source: Node = array[0]
	var damage_type: HealthModule.DamageType = array[1]

	death_type = damage_type

	match damage_type:
		HealthModule.DamageType.STRIKE:
			actor.velocity.x = source.velocity.x - sign(source.position.x - actor.position.x) * strike_x_power
			actor.velocity.y = -strike_y_power
			actor.anime.play(&"die_strike")

		HealthModule.DamageType.SQUISH:
			SFX.play_sfx(stomp_sfx, &"Motion", self)
			actor.doll.animation = &"squish"
			actor.anime.play(&"die_squish")
			actor.anime.animation_finished.connect(func(_anim_name: StringName): ready_to_perish = true)


func _trans_rules() -> Variant:
	return &""
