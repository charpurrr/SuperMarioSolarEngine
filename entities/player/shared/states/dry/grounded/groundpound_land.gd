class_name GroundPoundLand
extends PlayerState
## Landing after a groundpound.

## If the player can simply cancel out of the groundpound landing.
@export var can_ignore: bool = true

@export var camera_shake_power: int = 6


func _on_enter(_param):
	actor.vel.x = 0

	actor.camera.shake(Math.random_coord(camera_shake_power))


func _trans_rules():
	if movement.can_spin() and input.buffered_input(&"spin"):
		return &"Spin"

	if input.buffered_input(&"jump"):
		return &"GroundPoundJump"

	if Input.is_action_pressed(&"crouch"):
		return [&"Crouch", [true, true]]

	if can_ignore and InputManager.is_moving_x():
		return &"Idle"
	elif not actor.doll.is_playing():
		return &"Idle"

	return &""
