class_name Airborne
extends PlayerState
## A base state for all airborne states.


func _physics_tick(_delta: float):
	actor.set_floor_snap_length(0.0)

	actor.stomp_hurtbox.monitoring = actor.velocity.y > 0

	if actor.is_on_ceiling() and actor.velocity.y < 0 and not live_substate is GroundPound:
		for sfx_list in sfx_layers:
			sfx_list.play_sfx_at(self)


func _on_exit() -> void:
	actor.stomp_hurtbox.monitoring = false


func _trans_rules():
	if actor.is_on_floor():
		return [&"Grounded", not live_substate is GroundPound]

	if movement.active_coyote_time() and input.buffered_input(&"jump"):
		return &"Jump"

	return &""


func _defer_rules():
	return &"Fall"


func _on_stomp_hurt_box_body_entered(body: Node2D) -> void:
	if body is Enemy and body.health_module.hp != 0:
		body.health_module.damage(actor, HealthModule.DamageType.SQUISH, 1)

		if not get_leaf() is GroundPoundFall:
			manager.set_to_state(&"Jump", true)
	elif body is Breakable:
		body.shatter()
