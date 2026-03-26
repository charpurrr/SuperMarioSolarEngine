@tool
class_name PipeConnector
extends Sprite2D
## A connection piece between pipes.


@export_enum("Block", "Corner") var type: String:
	set(value):
		type = value
		_update_visual()
		notify_property_list_changed()

@export_enum("Left", "Down", "Up", "Right") var entry_dir: String:
	set(value):
		entry_dir = value
		_update_visual()
		notify_property_list_changed()

@export var exit_dir: String:
	set(value):
		exit_dir = value
		_update_visual()


func _update_visual() -> void:
	# Set the anchor point based on the
	offset = _get_direction(entry_dir) * 16
	
	# Match up the available exit directions
	# given the entry direction.
	match entry_dir:
		"Left", "Right":
			if exit_dir not in ["Up", "Down"]:
				exit_dir = "Up"
		"Up", "Down":
			if exit_dir not in ["Left", "Right"]:
				exit_dir = "Left"
	
	# Apply the correct texture on the connector
	if type == "Corner":
		region_rect = _get_corner_rect()
	else:
		region_rect = Rect2(0, 32, 32, 32)


func _get_corner_rect() -> Rect2:
	var size := Vector2(32, 32)
	var pos := Vector2(32, 32)
	match [entry_dir, exit_dir]:                 
		["Down", "Left"], ["Right", "Up"]:
			pos = Vector2(64, 32)
		["Up", "Right"], ["Left", "Down"]:
			pos = Vector2(32, 0)
		["Up", "Left"], ["Right", "Down"]:
			pos = Vector2(64, 0)
	return Rect2(pos, size)


func get_end_point():
	return position + _get_direction(exit_dir) * 16 + offset


func get_debug_point():
	return position + _get_direction(entry_dir) * 16

 
func _get_direction(dir) -> Vector2:
	match dir:
		"Left": return Vector2.LEFT
		"Down": return Vector2.DOWN
		"Up": return Vector2.UP
		"Right": return Vector2.RIGHT
	return Vector2.LEFT


func _validate_property(property: Dictionary) -> void:
	if property.name in ["entry_dir", "exit_dir"]:
		if type != "Corner":
			property.usage = PROPERTY_USAGE_NO_EDITOR
			return
	if property.name == "exit_dir":
		property.hint = PROPERTY_HINT_ENUM
		property.hint_string = "Up,Down" if entry_dir in ["Left", "Right"] else "Left,Right"
