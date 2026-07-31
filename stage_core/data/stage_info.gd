class_name StageInfo
extends SerializedResource
## Meta-data about a [Stage].
## Contains information that's shown in a level-browser setting
## like its name, author, and description.

@export var name: StringName = ""
@export var author: StringName = ""
@export_multiline() var description: String = ""


func serialize() -> String:
	return ""


## Take a piece of level code created by the [method serialize] method and decode it,
## then plug that data into this object's properties.
func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
