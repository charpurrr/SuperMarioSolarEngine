class_name PlayerStateManager
extends StateManager
## Root node of a player state machine.
## Adds player specialised variables and functions.

@export var input: InputManager
@export var fludd: FluddManager
@export var movement: PMovement


func _physics_process(delta):
	super(delta)

	var state: PlayerState = get_leaf()

	if state in movement.squash_stretch_states:
		if state in movement.squash_stretch_invert:
			_do_squash_stretch(true)
		else:
			_do_squash_stretch(false)


## Squash and stretch animations based on velocity.
func _do_squash_stretch(invert_axis: bool) -> void:
	var squash_stretch_amount: float = actor.get_real_velocity().y * movement.squash_stretch_intensity

	var new_scale: Vector2
	
	if not invert_axis:
		new_scale = Vector2(
			1.0 + squash_stretch_amount,
			1.0 - squash_stretch_amount
		)
	else:
		new_scale = Vector2(
			1.0 - squash_stretch_amount,
			1.0 + squash_stretch_amount
		)

	if movement.squash_stretch_tween:
		movement.squash_stretch_tween.kill()

	movement.squash_stretch_tween = movement.create_tween()
	movement.squash_stretch_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)

	movement.squash_stretch_tween.tween_property(
		actor.doll,
		^"scale",
		new_scale,
		movement.squash_stretch_duration
	)

	#movement.squash_stretch_tween.tween_property(
		#actor.doll,
		#^"scale:x",
		#new_scale.x,
		#movement.squash_stretch_duration_seconds
	#)
#
	#movement.squash_stretch_tween.parallel().tween_property(
		#actor.doll,
		#^"scale:y",
		#new_scale.y,
		#movement.squash_stretch_duration_seconds
	#)


func stop_squash_stretch() -> void:
	if not is_instance_valid(movement.squash_stretch_tween):
		return

	movement.squash_stretch_tween.kill()
	actor.doll.scale = Vector2.ONE


func _custom_passdowns() -> Dictionary[StringName, Variant]:
	return {
		&"input": input,
		&"fludd": fludd,
		&"movement": movement,
	}
