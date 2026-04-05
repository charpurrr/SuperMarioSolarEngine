@tool
class_name PipeExtension
extends TextureRect
## A variable-length extension piece for a [PipeSegment] in a [WarpPipe].
##
## Rotates and flips to face the correct direction, and tiles its texture
## to fill the segment's length without stretching.

## The direction this extension travels toward.
## Changing this rotates and flips the texture to match.
@export_enum("Left", "Down", "Up", "Right") var direction: String = "Up":
	set(val):
		direction = val

		match val:
			"Up":
				rotation = PI
				flip_h = true
			"Left":
				rotation = PI/2
				flip_h = true
			"Right":
				rotation = -PI/2
				flip_h = false
			"Down":
				rotation = 0
				flip_h = false


## Returns the world-space point where the next [PipeSegment] should begin.
func get_end_point() -> Vector2:
	var end_point_direction = Vector2.LEFT

	match direction:
		"Down": end_point_direction = Vector2.DOWN
		"Up": end_point_direction = Vector2.UP
		"Right": end_point_direction = Vector2.RIGHT

	var end_point_pos = end_point_direction * size.y + Vector2(size.x/2, 0)

	return position + end_point_pos
