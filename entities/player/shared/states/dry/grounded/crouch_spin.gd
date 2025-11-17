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
		if actor.vel.x == 0:
			return &"Backflip"

		return &"Longjump"

	return &""


func _on_crouch_spin_hurt_box_body_entered(body: Node2D) -> void:
	if not _is_live():
		return

	if body is Enemy:
		body.health_module.damage(actor, HealthModule.DamageType.STRIKE, 1)
	elif body is Breakable:
		body.shatter()
