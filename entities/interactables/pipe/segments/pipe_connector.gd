class_name PipeConnector
extends PipeSegment
## A connection piece between [PipeSegment]s.

@export_enum("Block", "Corner") var type: String
@export var entry_dir: Direction
@export var exit_dir: Direction
