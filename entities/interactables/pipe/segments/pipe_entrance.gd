@tool
class_name PipeEntrance
extends Sprite2D
## A pipe entrance or exit that the [Player] can enter or emerge from.
##
## Rotates and flips automatically to face the correct direction.
## Used by [WarpPipe] as both the entrance cap on the first segment
## and optionally as an exit cap at the far end.

## The direction this entrance faces.
@export_enum("Left", "Down", "Up", "Right") var direction: String = "Up":
	set(val):
		direction = val

		match val:
			"Up":
				rotation = 0
				flip_h = false
			"Left":
				rotation = -PI/2
				flip_h = false
			"Right":
				rotation = PI/2
				flip_h = true
			"Down":
				rotation = PI
				flip_h = true

## Identifier used to link this entrance to a destination when the player enters.
## Should match the [member exit_id] of the target [PipeEntrance] in another [WarpPipe].
@export var exit_id: String


## Returns the world-space end point of this entrance.
## For [PipeEntrance], this is always its own position since it is a terminal piece.
func get_end_point():
	return position
