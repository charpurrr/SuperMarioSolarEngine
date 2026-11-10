@tool
class_name PlayerSpawnData
extends Resource
## Defines how the [Player] is spawned.

## The state in which the [Player] should start.
## This name should correspond with the state's node name in the [Player] scene.
@export var starting_state: StringName = &"Airborne"

## The direction in which the [Player] will face.
@export_enum("Left", "Right") var starting_direction: int = 1:
	set(val):
		starting_direction = val
		emit_changed()

## The [Player]'s starting velocity.
@export var starting_velocity: Vector2

@export var offset: Vector2:
	set(val):
		offset = val
		emit_changed()
