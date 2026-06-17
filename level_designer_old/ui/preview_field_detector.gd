extends Control

## Emitted when the preview field starts or stops being hovered over with the cursor.
signal hover_updated()

var cursor_in_preview_field: bool:
	set(value):
		cursor_in_preview_field = value
		hover_updated.emit()


func _on_mouse_entered() -> void:
	cursor_in_preview_field = true


func _on_mouse_exited() -> void:
	cursor_in_preview_field = false
