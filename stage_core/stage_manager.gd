class_name StageManager
extends KeyScene
## Handles the instantiation of the current [Stage].

@export var current_stage: Stage


func _on_transition_to(_handover: Variant) -> void:
	TransitionManager.greenlight_load_in()


func _on_transition_from() -> void:
	pass
