class_name PipeEntrance
extends PipeSegment
## A [PipeSegment] that the [Player] can enter or exit from.

const ENTRANCE_SCENE := preload("res://entities/interactables/pipe/segments/pipe_entrance.tscn")

@export var direction := Direction.UP
@export var exit_id: String
