class_name Dry
extends PlayerState
## The opposite of [Submerged] (in water.)
## Handles all the other non-water states. (I.e. grounded and airborne states)


func _on_enter(_handover):
	pass


func _trans_rules():
	if movement.is_submerged():
		return &"Submerged"

	return &""


func _defer_rules():
	return &"LazyJump"
