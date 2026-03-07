class_name FluddManager
extends Node
## Handles communication between PlayerStates in regards to FLUDD.

@export var stamina_fade_in: float = 0.2
@export var stamina_fade_out: float = 0.1
@export_subgroup("Hover Nozzle", "hover")
## How powerfull the hover nozzle's boost is.
@export var hover_power: float = 1.5
## How fast you accelerate while hovering.
@export var hover_accel: float = 0.5
## How much fuel the hover nozzle uses up (percentage/frame.)
@export var hover_fuel_usage: float = 0.03
## How much stamina the hover nozzle uses up (percentage/frame.)
@export var hover_exhaustion: float = 1.1
## How effective the hover nozzle is the more stamina is depleted.[br]
## [i]Note: this should stay a [b]unit curve[/b] (ranging from 0-1 on both axis.)
@export var hover_effectiveness: Curve
## The water sounds that plays while using the hover nozzle.
@export var hover_spray_sfx: AudioStreamWAV

@export_subgroup("Rocket Nozzle", "rocket")
@export var rocket_power: float = 10.0
@export_subgroup("Turbo Nozzle", "turbo")
@export var turbo_power: float = 3.0

@export_category("References")
@export var actor: Player

@export var stamina_bar: TextureProgressBar
## How much stamina is left. (in percent)
var stamina: float = 100:
	set(val):
		stamina = clamp(val, 0.0, 100.0)

		if is_instance_valid(stamina_bar):
			stamina_bar.value = stamina

## FLUDD sprites that show behind the player.
@export var fludd_b: AnimatedSprite2D
## FLUDD sprites that show infront of the player.
@export var fludd_f: AnimatedSprite2D

@export var spray_player: AudioStreamPlayer

@export_category("Audio")
@export var toggle_sfx: AudioStream
@export var switch_sfx: AudioStream

enum Nozzle{
	NONE,
	HOVER,
	ROCKET,
	TURBO,
}

var available_nozzles: Array[Nozzle] = [
	Nozzle.NONE,
	Nozzle.HOVER,
	#Nozzle.ROCKET,
	#Nozzle.TURBO,
	]

## Which nozzle the player is currently using.
static var active_nozzle: Nozzle = Nozzle.NONE
## How much water is left in the FLUDD tank. (in percent)
static var fuel: float = 100.0:
	set(val):
		fuel = clamp(val, 0.0, 100.0)


## The base behaviour of the hover nozzle.
## Boosts you in the direction of the player's body rotation and plays a sound.
func hover() -> void:
	var rot_vec := Vector2.UP.rotated(actor.movement.body_rotation)
	var power_effectiveness = hover_effectiveness.sample_baked(1 - stamina / 100.0)
	var boost_vec: Vector2 = rot_vec * (hover_power * power_effectiveness)

	if abs(actor.velocity.x) < abs(boost_vec.x):
		actor.velocity.x += hover_accel * rot_vec.x

	if (sign(rot_vec.y) * (actor.velocity.y - boost_vec.y) < 0):
		actor.velocity.y += hover_accel * rot_vec.y

	stamina -= hover_exhaustion
	fuel -= hover_fuel_usage

	spray_player.play(hover_spray_sfx.get_length() * (1 - stamina / 100.0))


func switch_nozzle() -> void:
	var current_id: int = available_nozzles.find(active_nozzle)

	active_nozzle = available_nozzles[wrapi(current_id + 1, 0, available_nozzles.size())]

	get_tree().call_group("%s/sfx" % name, &"queue_free")

	if active_nozzle != Nozzle.NONE:
		SFX.play_sfx(switch_sfx, &"SFX", self)
		fludd_b.visible = true
		fludd_f.visible = true

		# Set the appropriate spray sound.
		match active_nozzle:
			Nozzle.HOVER:
				spray_player.set_stream(hover_spray_sfx)
	else:
		SFX.play_sfx(toggle_sfx, &"SFX", self)
		fludd_b.visible = false
		fludd_f.visible = false


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"switch_nozzle"):
		switch_nozzle()


func _ready() -> void:
	active_nozzle = Nozzle.NONE
	stamina_bar.visible = false
	fludd_b.visible = false
	fludd_f.visible = false


func _process(_delta: float) -> void:
	# Syncs up FLUDD's rotation with the player's sprite rotation.
	fludd_b.rotation = actor.doll.rotation
	fludd_f.rotation = actor.doll.rotation


func _physics_process(_delta: float) -> void:
	if active_nozzle == Nozzle.NONE:
		stamina_bar.modulate = Math.lerp_colr(stamina_bar.modulate, Color.TRANSPARENT, stamina_fade_out, 0.01)
		return

	if stamina == 100:
		stamina_bar.modulate = Math.lerp_colr(stamina_bar.modulate, Color.TRANSPARENT, stamina_fade_out, 0.01)

	if actor.is_on_floor():
		stamina = 100

	# Called here instead of _input() to avoid ignorance when holding the action key.
	if Input.is_action_pressed(&"use_fludd"):
		if stamina == 0 or fuel == 0:
			return

		stamina_bar.modulate = Math.lerp_colr(stamina_bar.modulate, Color.WHITE, stamina_fade_in, 0.01)
		stamina_bar.visible = true

		match active_nozzle:
			Nozzle.HOVER:
				hover()
	else:
		spray_player.stop()
