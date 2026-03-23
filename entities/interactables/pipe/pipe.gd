@tool
class_name WarpPipe
extends Node2D
## Pipe that can be entered to send the player to a new location.

@export var segments: Array[PipeSegment]


var connection_points := PackedVector2Array([Vector2.ZERO])


func _ready() -> void:
	for seg in segments:
		if seg is PipeEntrance:
			_create_pipe_entrance(seg, connection_points[segments.find(seg)])
		elif seg is PipeExtension:
			_create_pipe_extension(seg, connection_points[segments.find(seg)])


func _create_pipe_entrance(segment: PipeEntrance, where: Vector2) -> void:
	var node := segment.ENTRANCE_SCENE.instantiate() as Sprite2D
	var rot_vec := _get_vec_from_dir(segment.direction)

	node.rotate(rot_vec.angle() + PI / 2)
	node.flip_h = (
		segment.direction == PipeSegment.Direction.DOWN or
		segment.direction == PipeSegment.Direction.RIGHT
	)

	node.position = where
	next_connection_point = where

	add_child(node)


func _create_pipe_extension(segment: PipeExtension, where: Vector2) -> void:
	var node := segment.EXTENSION_SCENE.instantiate() as TextureRect
	node.size.y = segment.length
	add_child(node)


func _get_vec_from_dir(dir: PipeSegment.Direction) -> Vector2:
	match dir:
		PipeSegment.Direction.UP:
			return Vector2.UP
		PipeSegment.Direction.DOWN:
			return Vector2.DOWN
		PipeSegment.Direction.LEFT:
			return Vector2.LEFT
		PipeSegment.Direction.RIGHT:
			return Vector2.RIGHT
		_:
			return Vector2.ZERO
