class_name Breakable
extends Node2D
## An entity that can be broken in various ways.

## What sound effect plays when broken.
@export var break_sound: AudioStreamWAV
## What particle effect plays when broken.
@export var break_particles: ParticleEffect
## How many coins are in this container.
@export var contained_coins: int = 0
@export_category("References")
@export var sprite: Node2D
@export var collision: CollisionShape2D

var finished_calls: int = 0


## Break the object.
func shatter() -> void:
	var sfx: AudioStreamPlayer = SFX.play_sfx(break_sound, &"SFX", self)
	sfx.finished.connect(_count_finished)

	sprite.visible = false
	collision.set_deferred(&"disabled", true)

	var particle: CPUParticles2D = break_particles.emit_at(self)
	particle.finished.connect(_count_finished)


## Waits for both the sound effect's and the particle's [signal finished] signals
## before deleting this object.
func _count_finished():
	finished_calls += 1

	if finished_calls == 2:
		queue_free()
