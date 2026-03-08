class_name Hit
extends PlayerState
## Getting hit and taking damage.

## How long the game freezes after you get hit.
@export var freeze_time: int = 10
var freeze_timer: int

## Which color the player flashes while freezed.
@export var freeze_flash_modulate: Color = Color.RED
## How many times the player flashes while freezed.
@export var freeze_flashes: int = 6

## For how many frames the player gains invincibility after being hit.
@export var i_frames: int = 30

## The strength at which the camera shakes when hit.
@export var camera_shake_power: int = 6

## The associated sound effects for every [enum HealthModule.DamageType].
@export var sfx: Dictionary[HealthModule.DamageType, Array]


func _on_enter(params: Variant) -> void:
	#var source: Node = param[0]
	var damage_type: HealthModule.DamageType = params[1]

	actor.velocity = Vector2.ZERO
	freeze_timer = freeze_time

	for sfx_layer: SFXLayer in sfx.get(damage_type):
		sfx_layer.play_sfx_at(self)

	actor.doll.self_modulate = freeze_flash_modulate

	actor.camera.shake(Math.random_coord(camera_shake_power))
	actor.health_module.enabled = false

	Engine.time_scale = 0.0

	var freeze_duration := freeze_time / Engine.get_frames_per_second()
	var flash_interval := freeze_duration / (freeze_flashes * 2.0)

	_flash_loop(flash_interval)

	await get_tree().create_timer(freeze_duration, true, false, true).timeout
	Engine.time_scale = 1.0

	actor.doll.self_modulate = Color.WHITE


func _flash_loop(interval: float) -> void:
	for i in freeze_flashes * 2:
		actor.doll.self_modulate = freeze_flash_modulate if i % 2 == 0 else Color.WHITE
		await get_tree().create_timer(interval, true, false, true).timeout


func _physics_tick(_delta: float) -> void:
	freeze_timer = max(freeze_timer - 1, 0)


func _trans_rules() -> Variant:
	if freeze_timer == 0:
		actor.health_module.grant_i_frames(actor, i_frames)
		return &"Airborne"

	return &""
