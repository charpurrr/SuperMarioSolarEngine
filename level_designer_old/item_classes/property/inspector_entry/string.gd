extends InspectorEntry

@export var input: LineEdit

func set_value(value: Variant) -> void:
	input.text = value
