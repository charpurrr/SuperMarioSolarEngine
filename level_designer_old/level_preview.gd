class_name LevelPreview
extends Node2D

var brush_item: PreviewItem


func new_brush(item_data: EditorItemData):
	if brush_item != null:
		brush_item.queue_free()
	brush_item = spawn_item(item_data)
	brush_item.grab()


func spawn_item(item_data: EditorItemData) -> PreviewItem:
	var inst = item_data.create_preview()
	add_child(inst)
	inst.position = get_local_mouse_position()
	return inst


func _unhandled_input(event):
	if event.is_action_pressed(&"select") and brush_item != null:
		spawn_item(brush_item.item_data)


func _process(_delta):
	if brush_item != null:
		brush_item.position = get_local_mouse_position()


func cancel_brush():
	if brush_item != null:
		brush_item.queue_free()
		brush_item = null
