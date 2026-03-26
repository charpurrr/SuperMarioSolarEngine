@tool
class_name PipeExtension
extends TextureRect
## The extension of the pipe.


@export_enum("Left", "Down", "Up", "Right") var direction: String = "Up":
	set(value):
		direction = value
		match value:
			"Up": rotation = PI
			"Left": rotation = .5*PI
			"Right": rotation = -.5*PI
			"Down": rotation = 0
		flip_h = value in ["Left", "Up"]


func get_end_point():
	var end_point_direction = Vector2.LEFT
	match direction:
		"Down": end_point_direction = Vector2.DOWN
		"Up": end_point_direction = Vector2.UP
		"Right": end_point_direction = Vector2.RIGHT
	return position + end_point_direction * size.y * scale.y + Vector2(16, 0)
