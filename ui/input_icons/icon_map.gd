class_name IconMap
extends Node
## Utility class for finding the associated icon with an InputEvent.

## The dictionary that defines which actions correspond to which icons.
static var icon_map: Resource = preload("uid://cqn6pfhri63v7")
## Dictionary that defines the events in [member icon_map] as strings.
## (These strings are hashed, which is why the key is typed as an integer.)
static var event_map: Dictionary[int, InputEvent] = {}


static func _static_init() -> void:
	if event_map.is_empty():
		for _event: InputEvent in icon_map.dictionary:
			if _event != null:
				event_map.set(_event.as_text().hash(), _event)


## Returns the human-readable name of an InputEvent without any modifiers.
## This is how you should usually go about using events with the [IconMap].
static func get_filtered_name(event: InputEvent) -> String:
	var event_name: String = ""

	if event is InputEventKey:
		event_name = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		event_name = event.as_text().rsplit("+", true, 1)[-1].replace(" (Double Click)", "")
	elif event is InputEventJoypadButton:
		event_name = event.as_text()
	else:
		event_name = ""  # Unknown or unsupported input type

	return event_name


## Returns the InputEvent associated with [param filtered_name].
static func get_associated_event(filtered_name: String) -> InputEvent:
	return event_map.get(filtered_name.hash())


## Returns the associated icon graphic for an [InputEvent].
static func find(event: InputEvent) -> CompressedTexture2D:
	var key: String = get_filtered_name(event)
	return icon_map.dictionary.get(event_map.get(key.hash()), null)
