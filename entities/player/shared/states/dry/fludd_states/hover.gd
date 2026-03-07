class_name Hover
extends LazyJump
## Using the Hover nozzle.

@export_range(0, 360) var rotate: float = 3.0
@export var rotate_speed: float


func _physics_tick(delta: float):
	super(delta)

	if not actor.movement.is_submerged():
		_dry_logic()
	else:
		_submerged_logic()


## While underwater.
func _submerged_logic():
	pass


## While outside of water.
func _dry_logic():
	actor.doll.rotation = rotate_toward(actor.doll.rotation, rotate * actor.movement.get_input_x(), rotate_speed)
