extends InspectorEntry

@export var component_label: Label
@export var input: SpinBox


func set_component_label(text: String) -> void:
	component_label.text = text


func set_value(value: Variant) -> void:
	input.value = value


func get_value() -> float:
	return input.value
