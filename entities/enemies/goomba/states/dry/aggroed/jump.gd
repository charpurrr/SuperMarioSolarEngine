class_name GoombaJump
extends EnemyState
## Jump towards the player, and attempt to jump over obstacles.

@export var jump_power: float = 4.0
@export var jump_decel: float = 0.1

## How close the player needs to be in order for the Goomba to decelerate while airborne.
@export var range_jump := Vector2(10.0, 10.0)

@export_category(&"Animation (Unique to State)")
@export var jump_animation: StringName
@export var jump_offset := Vector2.ZERO
@export var fall_animation: StringName
@export var fall_offset := Vector2.ZERO


func _on_enter(jump_power_overwrite: Variant) -> void:
	actor.vel.y -= jump_power if jump_power_overwrite == null else jump_power_overwrite


func _physics_tick() -> void:
	if actor.vel.y > 0:
		actor.doll.play(fall_animation)
		actor.doll.offset = fall_offset
	else:
		actor.doll.play(jump_animation)
		actor.doll.offset = jump_offset

	if actor.spotted_player == null:
		return

	actor.diff = actor.spotted_player.global_position - actor.global_position

	if abs(actor.diff.x) <= range_jump.x and actor.diff.y <= range_jump.y:
		actor.vel.x = move_toward(actor.vel.x, 0, jump_decel)


func _trans_rules() -> Variant:
	if actor.is_on_floor():
		return &"Chase"

	return &""
