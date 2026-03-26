@tool
class_name PipeEntrance
extends Sprite2D
## A pipe that the [Player] can enter or exit from.

@export_enum("Left", "Down", "Up", "Right") var direction: String = "Up":
	set(value):
		direction = value
		match value:
			"Up": rotation = 0
			"Left": rotation = -.5*PI
			"Right": rotation = .5*PI
			"Down": rotation = PI
		flip_h = value in ["Right", "Down"]
		
@export var exit_id: String


func get_end_point():
	return position


func get_debug_point():
	return position
