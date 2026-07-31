class_name MissionInfo
extends SerializedResource
## Provides information about a [Stage]'s mission.


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
