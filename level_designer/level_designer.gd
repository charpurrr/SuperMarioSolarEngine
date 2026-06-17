class_name LevelDesigner
extends KeyScene


func _on_transition_to(_handover: Variant) -> void:
	TransitionManager.greenlight_load_in()


## Runs when this [KeyScene] is being transitioned from.
func _on_transition_from() -> void:
	pass
