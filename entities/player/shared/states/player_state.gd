class_name PlayerState
extends State
## State specialised for player characters.

@export_enum("Normal", "Small", "Dive", "None") var hitbox_type: String = "Normal"

@export_category(&"Visual")
@export var animation_data: PStateAnimData
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

var input: InputManager = null
var fludd: FluddManager = null
var movement: PMovement = null

var overwrite_setup_finished: bool


func trigger_enter(handover) -> void:
	if is_instance_valid(animation_data):
		_set_animation()
		actor.doll.frame_changed.connect(_set_frame_specs)

		# We have to call this manually at the start of a state because
		# the animation might change. Otherwise we'll have the wrong offsets
		# for for the first frame of the new animation.
		_set_frame_specs()

	overwrite_setup_finished = false

	_set_hitbox()

	set_modules(true)
	emit_particles()
	play_sounds()

	super(handover)


func trigger_exit() -> void:
	super()

	set_modules(false)

	if actor.doll.frame_changed.is_connected(_set_frame_specs):
		actor.doll.frame_changed.disconnect(_set_frame_specs)

	for layer in sfx_layers:
		if not layer.cutoff_sfx:
			continue

		for child in get_children():
			if child is AudioStreamPlayer and child.stream in layer.sfx_list:
				child.queue_free()


## Uses [parameter new_data] as the state's animation data.[br]
## This function is best called in a state's [method _physics_tick].
## [i]Note: the default [member animation_data] variable should be left empty
## to avoid issues while using this.
func overwrite_animation(new_data: PStateAnimData) -> void:
	if not overwrite_setup_finished:
		actor.doll.frame_changed.connect(_set_frame_specs.bind(new_data))
		_set_frame_specs(new_data)
		overwrite_setup_finished = true

	actor.doll.play(new_data.animation)


func set_modules(enable: bool) -> void:
	for child in get_children():
		## ADD NEW MODULES UNDERNEATH HERE
		if child is AfterimageModule:
			child.enabled = enable


func play_sounds() -> void:
	if on_enter and not sfx_layers.is_empty():
		for sfx_list in sfx_layers:
			sfx_list.play_sfx_at(self)


func emit_particles() -> void:
	for effect in particles:
		effect.emit_at(actor)


func _set_hitbox() -> void:
	if hitbox_type == "None":
		return

	var was_diving = not actor.dive_hitbox.disabled

	actor.hitbox.disabled = true
	actor.small_hitbox.disabled = true
	actor.dive_hitbox.disabled = true

	match hitbox_type:
		"Normal":
			_snap_dive_to_ground(was_diving)
			actor.hitbox.disabled = false
		"Small":
			_snap_dive_to_ground(was_diving)
			actor.small_hitbox.disabled = false
		"Dive":
			actor.dive_hitbox.disabled = false


## Snap back to the ground if you exit from a dive hitbox to a non-dive hitbox.
func _snap_dive_to_ground(was_diving: bool) -> void:
	if was_diving:
		actor.global_position.y -= actor.dive_hitbox.get_shape().get_rect().size.y / 2


func _set_animation() -> void:
	if not animation_data.animation.is_empty():
		actor.doll.play(animation_data.animation)


## Sets the appropriate frame specifications. (Offsets, FLUDD animation, FLUDD offset)
func _set_frame_specs(overwrite_data: PStateAnimData = null) -> void:
	var data: PStateAnimData = overwrite_data

	if data == null:
		data = animation_data

	actor.doll.offset = data.frame_offsets.get(actor.doll.frame, Vector2i.ZERO)

	actor.fludd_b.offset = data.frame_fludd_offsets.get(actor.doll.frame, Vector2i.ZERO)
	actor.fludd_b.offset.x *= actor.movement.facing_direction
	actor.fludd_f.offset = data.frame_fludd_offsets.get(actor.doll.frame, Vector2i.ZERO)
	actor.fludd_f.offset.x *= actor.movement.facing_direction

	actor.fludd_b.animation = data.frame_fludd.get(actor.doll.frame, "default")
	actor.fludd_f.animation = data.frame_fludd.get(actor.doll.frame, "default")
