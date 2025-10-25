class_name GoombaRoam
extends EnemyState
## Walking around, looking for the player.


func _trans_rules() -> Variant:
	if actor.spotted_player != null:
		return &"Aggroed"

	return &""


func _defer_rules():
	return &"Idle"


func _on_detection_area_body_entered(body: Node2D) -> void:
	actor.spotted_player = body
