class_name Dry
extends PlayerState
## The opposite of [Submerged] (in water.)
## Handles all the other non-water states. (I.e. grounded and airborne states)

func _physics_tick(_delta: float) -> void:
	if actor.state_manager.get_leaf() in movement.squash_stretch_dry_blacklist:
		stop_squash_stretch()
		return

	## Squash/stretch stuff
	var squash_stretch_amount: float = actor.get_real_velocity().y * movement.squash_stretch_intensity
	var new_scale: Vector2 = Vector2(
		1.0 + squash_stretch_amount,
		1.0 - squash_stretch_amount
	)

	if movement.squash_stretch_tween: movement.squash_stretch_tween.kill()
	movement.squash_stretch_tween = movement.create_tween()
	movement.squash_stretch_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	movement.squash_stretch_tween.tween_property(
		actor.doll,
		^"scale:x",
		new_scale.x,
		movement.squash_stretch_duration_seconds
	)
	movement.squash_stretch_tween.parallel().tween_property(
		actor.doll,
		^"scale:y",
		new_scale.y,
		movement.squash_stretch_duration_seconds
	)

func stop_squash_stretch() -> void:
	movement.squash_stretch_tween.kill()
	actor.doll.scale = Vector2.ONE

func _on_enter(_handover):
	pass


func _on_exit() -> void:
	stop_squash_stretch()

func _trans_rules():
	if movement.is_submerged():
		return &"Submerged"

	return &""


func _defer_rules():
	return &"LazyJump"
