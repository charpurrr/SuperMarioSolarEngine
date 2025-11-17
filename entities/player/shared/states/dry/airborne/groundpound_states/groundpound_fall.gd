class_name GroundPoundFall
extends PlayerState
## Falling after performing a ground pound.

## How fast you ground pound.
@export var gp_fall_vel: float = 9.0


func _on_enter(_param: Variant) -> void:
	actor.gp_hurtbox.monitoring = true


func _physics_tick():
	movement.move_x_analog(0.04, false)

	actor.vel.y = gp_fall_vel


func _on_exit() -> void:
	actor.gp_hurtbox.monitoring = false


func _trans_rules():
	if actor.is_on_floor():
		if movement.is_slide_slope():
			return [&"ButtSlide", gp_fall_vel]
		else:
			return &"GroundPoundLand"

	if not movement.dived and movement.can_air_action() and input.buffered_input(&"dive"):
		return &"Dive"

	if input.buffered_input(&"up"):
		return &"GroundPoundCancel"

	return &""


func _on_groundpound_hurt_box_body_entered(body: Node2D) -> void:
	if body is Enemy:
		body.health_module.damage(actor, HealthModule.DamageType.SQUISH, 2);
	elif body is Breakable:
		body.shatter()
