class_name MissionInfo
extends SerializedResource
## Provides information about a mission within a [Stage].


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
