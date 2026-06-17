extends PropertyDisplay


func set_value(new_value: Variant) -> void:
	new_value = new_value as Color
	preview_display.modulate = new_value
