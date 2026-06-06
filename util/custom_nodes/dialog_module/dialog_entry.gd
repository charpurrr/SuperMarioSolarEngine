@tool
class_name DialogEntry
extends Resource
## A resource defining a part of a broader [DialogModule].

@export_multiline var text: String

@export var has_choices: bool:
	set(val):
		has_choices = val
		notify_property_list_changed()

@export var choices: PackedStringArray


func _validate_property(property: Dictionary) -> void:
	if not has_choices and property.name == "choices":
		property.usage = PROPERTY_USAGE_NO_EDITOR
