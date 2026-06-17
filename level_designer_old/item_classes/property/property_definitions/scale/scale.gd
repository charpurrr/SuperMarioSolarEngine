extends PropertyDisplay


func set_value(new_value: Variant) -> void:
	new_value = new_value as Vector2
	preview_display.scale = new_value
	preview_item.selection_shape.scale = new_value
