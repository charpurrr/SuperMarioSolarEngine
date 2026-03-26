class_name Util
## Provides useful functions that you can call using [code]Util.function_name[/code].


## Resets the mouse cursor graphic to that defined in the project settings.
static func set_cursor_to_default():
	var default_cursor_image: Resource = load(
		ProjectSettings.get_setting("display/mouse_cursor/custom_image")
		)

	Input.set_custom_mouse_cursor(
		default_cursor_image,
		Input.CURSOR_ARROW,
		ProjectSettings.get_setting("display/mouse_cursor/custom_image_hotspot")
	)


## Returns the default events of [param action] from the [ProjectSettings].[br]
## The [param as_strings] parameter makes it return as a PackedStringArray.
static func get_default_events(action: String, as_strings: bool = false) -> Variant:
	var action_path: String = "input/" + action
	var action_data: Dictionary = ProjectSettings.get(action_path)

	if not as_strings:
		return action_data["events"]
	else:
		var names := PackedStringArray()
		for event in action_data["events"]:
			names.append(IconMap.get_filtered_name(event))

		return names


## Gets scene root for editor purposes
static func get_scene_root(node: Node) -> Node:
	var current = node
	var last_valid = node
	while current.get_parent() != null:
		current = current.get_parent()
		if "@" not in current.name:
			last_valid = current
	return last_valid


## Swaps two elements in an array given their indices.
## Also supports negative indices
static func swap(array: Array, idx_1: int, idx_2: int):
	var n = len(array)
	idx_1 = idx_1 if idx_1 >= 0 else n+idx_1
	idx_2 = idx_2 if idx_2 >= 0 else n+idx_2
	
	var temp = array[idx_1]
	array[idx_1] = array[idx_2]
	array[idx_2] = temp
