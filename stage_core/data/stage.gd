class_name Stage
extends SerializedResource
## Resource for all information about a playable stage.

## Stage meta-data.
@export var info: StageInfo

## List of all [Area]s within a [Stage].
@export var areas: Dictionary[StringName, Area]
## The default [Area] the [Player] starts the [Stage] in.
@export var default_area: StringName

## List of all missions within a [Stage].
@export var missions: Array[MissionInfo]

## Temporary level variables during playtime.
var cache := StageCache.new()


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
