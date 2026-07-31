class_name SpawnInfo
extends SerializedResource
## Information about how the [Player] spawns in an [Area].

## The location of the spawn point.
@export var spawn_pos: Vector2
## The initial velocity when spawning at this spawn point.
@export var spawn_vel: Vector2
## The intial facing direction when spawning at this spawn point.
## In combination with [member spawn_vel], can be used to send the [Player]
## in a direction at a certain velocity when spawning.
@export var spawn_dir: int = 1


func _init(_spawn_pos := Vector2.ZERO, _spawn_vel := Vector2.ZERO, _spawn_dir: int = 1) -> void:
	spawn_pos = _spawn_pos
	spawn_vel = _spawn_vel
	spawn_dir = _spawn_dir


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
