class_name CrouchSpin
extends Spin
## Spinning while crouching.


func _on_enter(param):
	super(param)

	actor.crouch_spin_hurtbox.monitoring = true


func _on_exit():
	actor.crouch_spin_hurtbox.monitoring = false


func _trans_rules():
	if not actor.doll.is_playing():
		return [&"Crouch", [true, false]]

	if movement.is_slide_slope():
		return &"ButtSlide"

	if not actor.auto_crouch_check.enabled and input.buffered_input(&"jump"):
		if actor.velocity.x == 0:
			return &"Backflip"

		return &"Longjump"

	return &""


func _on_crouch_spin_hurt_box_body_entered(body: Node2D) -> void:
	if not _is_live():
		return

	if body is Enemy:
		enemy_strike_sfx.play(actor)
		enemy_strike_pfx.emit_at(body)
		body.health_module.damage(actor, HealthModule.DamageType.STRIKE, 1)

		Engine.time_scale = enemy_strike_slow_factor
		var slow_duration := enemy_strike_slow_time / Engine.get_frames_per_second()
		await get_tree().create_timer(slow_duration, true, false, true).timeout
		Engine.time_scale = 1.0
	elif body is Breakable:
		body.shatter()
