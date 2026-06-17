class_name SelectTool
extends Tool
## Default all-purpose selection tool.

signal selection_changed(items: Array[PreviewItem])

var selected_items: Array[PreviewItem] = []
var selecting: bool
var point_start: Vector2
var point_end: Vector2

@onready var selection_box: NinePatchRect = toolbar.editor.selection_box
@onready var selection_area: Area2D = selection_box.selection_area
@onready var selection_shape: CollisionShape2D = selection_box.shape


func _ready():
	super()
	selection_area.area_entered.connect(item_entered)
	selection_area.area_exited.connect(item_exited)


func _tick():
	if not active:
		return
	if selecting:
		_set_point_end()

		var point_top_l := Vector2(min(point_start.x, point_end.x), min(point_start.y, point_end.y))
		var point_bot_r := Vector2(max(point_start.x, point_end.x), max(point_start.y, point_end.y))

		var center_size: Vector2 = point_bot_r - point_top_l

		var left: float = selection_box.patch_margin_left
		var right: float = selection_box.patch_margin_right
		var top: float = selection_box.patch_margin_top
		var bottom: float = selection_box.patch_margin_bottom

		selection_box.size = center_size + Vector2(left + right, top + bottom)
		selection_box.position = point_top_l - Vector2(left, right)

		selection_shape.position = center_size / 2 + Vector2(left, right)
		selection_shape.shape.size = center_size

	selection_box.visible = selecting


func _unhandled_input(event):
	if not active:
		return
	if selecting:
		if event.is_action_released(&"select"):
			selecting = false
			selection_changed.emit(selected_items)
	elif event.is_action_pressed(&"select"):
		selected_items.clear()
		_set_point_start()


func _set_point_start():
	point_start = selection_box.get_global_mouse_position()
	selecting = true


func _set_point_end():
	point_end = selection_box.get_global_mouse_position()


func _on_activate():
	selection_area.monitoring = true


func _on_deactivate():
	selection_area.monitoring = false


func item_entered(area: Area2D):
	if not active or not selecting:
		return
	var preview_item = area.get_parent()
	selected_items.append(preview_item)
	preview_item.select()


func item_exited(area: Area2D):
	if not active or not selecting:
		return
	var preview_item = area.get_parent()
	selected_items.erase(preview_item)
	preview_item.deselect()
