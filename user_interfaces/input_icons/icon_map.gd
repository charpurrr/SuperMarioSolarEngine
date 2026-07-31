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
		for event: InputEvent in icon_map.dictionary:
			if event != null:
				event_map.set(get_filtered_name(event).hash(), event)


## Returns the human-readable name of an InputEvent without any modifiers.
## This is how you should usually go about using events with the [IconMap].
static func get_filtered_name(event: InputEvent) -> String:
	var event_name: String = ""

	if event is InputEventKey:
		event_name = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		event_name = event.as_text().rsplit("+", true, 1)[-1].replace(" (Double Click)", "")
	elif event is InputEventMouseMotion:
		event_name = "Mouse Motion"
	elif event is InputEventJoypadButton:
		event_name = _joypad_button_name(event.button_index)
	elif event is InputEventJoypadMotion:
		event_name = _joypad_motion_name(event.axis, event.axis_value)
	else:
		push_warning("Filtered names for actions of type %s are unsupported." % event.get_class())
		event_name = ""  # Unknown or unsupported input type

	return event_name


## Returns the InputEvent associated with [param filtered_name].
static func get_associated_event(filtered_name: String) -> InputEvent:
	return event_map.get(filtered_name.hash())


## Returns the associated icon graphic for an [InputEvent].
static func find(event: InputEvent) -> CompressedTexture2D:
	var key: String = get_filtered_name(event)
	return icon_map.dictionary.get(event_map.get(key.hash()), null)


static func _joypad_button_name(button: int) -> String:
	match button:
		# Nintendo defaults since this is a Mario engine.
		JOY_BUTTON_A: return "B Button"
		JOY_BUTTON_B: return "A Button"
		JOY_BUTTON_X: return "Y Button"
		JOY_BUTTON_Y: return "X Button"

		JOY_BUTTON_LEFT_SHOULDER: return "Left Shoulder Button"
		JOY_BUTTON_RIGHT_SHOULDER: return "Right Shoulder Button"

		JOY_BUTTON_BACK: return "- Button"
		JOY_BUTTON_START: return "+ Button"
		JOY_BUTTON_GUIDE: return "Home Button"
		JOY_BUTTON_MISC1: return "Capture Button"

		JOY_BUTTON_LEFT_STICK: return "Left Stick"
		JOY_BUTTON_RIGHT_STICK: return "Right Stick"

		JOY_BUTTON_DPAD_UP: return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"

		_: return "Button %d" % button


static func _joypad_motion_name(axis: int, value: float) -> String:
	match axis:
		JOY_AXIS_LEFT_X:
			if value >= 0.0:
				return "Left Stick - Right"
			else:
				return "Left Stick - Left"
		JOY_AXIS_LEFT_Y:
			if value >= 0.0:
				return "Left Stick - Up"
			else:
				return "Left Stick - Down"
		JOY_AXIS_RIGHT_X:
			if value >= 0.0:
				return "Right Stick - Right"
			else:
				return "Right Stick - Left"
		JOY_AXIS_RIGHT_Y:
			if value >= 0.0:
				return "Right Stick - Up"
			else:
				return "Right Stick - Down"
		JOY_AXIS_TRIGGER_LEFT:
			return "Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT:
			return "Right Trigger"

		_: return "Axis %d%f" % [axis, value]
