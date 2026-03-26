@tool
class_name PipeSegment
extends Resource


@export_enum("Left", "Down", "Up", "Right") var direction: String:
	set(value):
		old_direction = direction
		direction = value
		notify_property_list_changed()
		updated_direction.emit()
var old_direction: String

@export var length: float:
	set(value):
		length = max(0, value)
		old_direction = direction
		updated.emit()

@export var is_block: bool:
	set(value):
		is_block = value
		old_direction = direction
		updated.emit()

var is_connector: bool = true
var idx: int

signal updated_direction
signal updated
var connected_updates: bool = false

var available_directions: PackedStringArray:
	set(value):
		if direction not in value:
			direction = value[0]
		available_directions = value
		notify_property_list_changed()


func _validate_property(property: Dictionary) -> void:
	if property.name == "direction":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = ",".join(available_directions)
	
	if not is_connector:
		if property.name == "is_block":
			property.usage = PROPERTY_USAGE_NO_EDITOR
	
	if property.name == "parent_node_path":
		property.usage = PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_READ_ONLY
