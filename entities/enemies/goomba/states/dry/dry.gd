class_name GoombaDry
extends EnemyState
## The opposite of [GoombaSubmerged] (in water.)
## Handles all the other non-water states. (I.e. roaming and aggroed states)


func _physics_tick(_delta: float) -> void:
	actor.vel.y += actor.gravity
