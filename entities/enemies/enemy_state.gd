class_name EnemyState
extends State
## State specialised for enemies.

#@export_category(&"Visual")
@export var animation: StringName
@export var animation_offset := Vector2.ZERO
## The associated particles that should emit when the state is activated.
@export var particles: Array[ParticleEffect]

@export_category(&"Sound")
## Whether or not the sound effect(s) should play as soon as the state starts.
@export var on_enter: bool = true
## sfx_layers is a list of the possible sound effects that can play at once.
## [br][br]This is useful if you want a state to play more than one sound on entry.
## [br][br]Every array inside of the sfx_layers array is said list of possible
## sound effects it can cycle through.
@export var sfx_layers: Array[SFXLayer]


func trigger_enter(handover) -> void:
	emit_particles()
	play_sounds()

	_set_animation()

	super(handover)


func trigger_exit() -> void:
	super()

	for layer in sfx_layers:
		if not layer.cutoff_sfx:
			continue

		for child in get_children():
			if child is AudioStreamPlayer and child.stream in layer.sfx_list:
				child.queue_free()


func play_sounds() -> void:
	if on_enter and not sfx_layers.is_empty():
		for sfx_list in sfx_layers:
			sfx_list.play_sfx_at(self)


func emit_particles() -> void:
	for effect in particles:
		effect.emit_at(actor)


func _set_animation() -> void:
	if not animation.is_empty():
		actor.doll.offset = animation_offset
		actor.doll.play(animation)
