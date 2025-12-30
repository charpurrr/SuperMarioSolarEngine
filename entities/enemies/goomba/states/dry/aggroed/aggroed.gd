class_name GoombaAggroed
extends EnemyState
## Having spot the player.

@export var notice_jump_power: int


func _trans_rules() -> Variant:
	if actor.spotted_player == null and actor.is_on_floor():
		return &"Roam"

	return &""


func _defer_rules() -> Variant:
	return [&"Jump", notice_jump_power]


func _on_detection_area_body_exited(_body: Node2D) -> void:
	actor.spotted_player = null
