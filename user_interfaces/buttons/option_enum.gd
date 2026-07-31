@tool
class_name OptionEnum
extends OptionBase
## UI button that can toggle between different defined states.

@export var options: Array[StringName]


func _pressed():
	var new_value: int = wrapi(value + 1, 0, options.size())
	change_setting(new_value)


func _update_button():
	text = options[value]
