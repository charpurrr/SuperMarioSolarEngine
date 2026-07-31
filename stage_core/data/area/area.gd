class_name Area
extends SerializedResource
## An area within a [Stage].
## Contains all the objects within this [Area] in layer format
## and its environmental configuration.

# Information about the player's spawn location within this [Area].
#@export var spawn_info: SpawnInfo
## Information about this [Area]'s environment.
@export var environment: AreaEnvironment
## List of object layers within this [Area].
@export var layers: Array[Layer]


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
