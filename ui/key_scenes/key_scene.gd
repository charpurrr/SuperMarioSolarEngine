@abstract
class_name KeyScene
extends Control
## Class for key screens, such as the Title Screen, Level Select screen,  Game World, or others that the TransitionManager can warp to if needed


func _ready() -> void:
	TransitionManager.current_key_screen = self


## Runs when this [KeyScene] is being transitioned from.
@abstract func _on_transition_to(_handover: Variant) -> void


## Runs when this [KeyScene] is being transitioned to.
@abstract func _on_transition_from() -> void
