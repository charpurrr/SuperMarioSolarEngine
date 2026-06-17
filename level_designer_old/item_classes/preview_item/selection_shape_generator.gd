@tool
class_name SelectionShapeGenerator
extends ResourceGenerator
## Generator and editor for selection shapes of editor items.

## Press to apply the edits made to the shape.
@export_tool_button("Apply Manual Edit", "CheckBox")
var edit_action: Callable = _save_edits

## An [EditorItemData] resource can be dragged here to edit it.
@export var manual_edit_item: EditorItemData = null:
	set(val):
		manual_edit_item = val
		_update_edit_preview()
	get:
		return manual_edit_item

## Reference to the [PreviewItem] used to preview the [EditorItemData].
var preview_display: Node2D = null

## The polygon that will be used to preview and edit selection shapes.
@onready var edit_polygon = $EditPolygon


## Saves edits to the selected item.
func _save_edits() -> void:
	var shape = ConvexPolygonShape2D.new()

	shape.points = edit_polygon.polygon
	manual_edit_item.preview_display_data.set_selection_shape(shape)

	_resave(manual_edit_item)

	print("Applied changes!")


## Updates the edit preview to match the selected edit item.
func _update_edit_preview() -> void:
	if edit_polygon == null:
		await ready
	_clear_edit_preview()
	if manual_edit_item == null:
		return

	var display_data = manual_edit_item.preview_display_data
	var shape = display_data.get_selection_shape()
	if shape == null:
		return

	if shape is ConvexPolygonShape2D:
		edit_polygon.polygon = shape.points
	elif shape is RectangleShape2D:
		var polygon = rect_size_to_polygon(shape.size)
		edit_polygon.polygon = polygon

	var inst = manual_edit_item.preview_display_data.create()
	preview_display = inst
	add_child(inst)


func rect_size_to_polygon(size: Vector2) -> PackedVector2Array:
	var halfsize = size * 0.5
	var polygon: PackedVector2Array = []

	# Clockwise mapping.
	for y in [-1, 1]:
		for x in [-1, 1]:
			polygon.append(Vector2(x * -y, y) * halfsize)

	return polygon


## Clears the edit preview.
func _clear_edit_preview() -> void:
	edit_polygon.polygon = []
	if preview_display != null:
		preview_display.queue_free()
		preview_display = null


func _is_correct_type(resource) -> bool:
	return resource is EditorItemData


func _process_all(filesystem, resource_list) -> void:
	var paths = PackedStringArray()
	for item in resource_list:
		item = item as EditorItemData

		var display_data = item.preview_display_data as PreviewDisplayData
		if display_data == null:
			continue

		if not display_data.needs_static_selection_shape():
			continue

		var shape = display_data.get_selection_shape()
		if shape != null:
			continue

		var texture: Texture2D = display_data.get_reference_texture()
		if texture == null:
			continue

		var new_shape = _shape_from_texture(texture)
		display_data.set_selection_shape(new_shape)

		_resave(item)
		paths.append(item.resource_path)

	filesystem.reimport_files(paths)

	_update_edit_preview()


func _shape_from_texture(texture) -> Shape2D:
	var image = texture.get_image()

	if image == null:
		# Probably a PlaceholderTexture2D, which cannot generate a proper image.
		assert(texture is PlaceholderTexture2D)
		var shape = RectangleShape2D.new()
		shape.size = texture.get_size()
		return shape

	var bitmap = BitMap.new()
	bitmap.create_from_image_alpha(image)

	var bitmap_size = bitmap.get_size()
	var polygons = bitmap.opaque_to_polygons(Rect2(Vector2.ZERO, bitmap_size))

	var connected_polygon = PackedVector2Array()
	for polygon in polygons:
		connected_polygon.append_array(polygon)

	var center_offset: Vector2 = bitmap_size / 2

	for i in connected_polygon.size():
		connected_polygon.set(i, connected_polygon[i] - center_offset)

	var final_shape = ConvexPolygonShape2D.new()
	final_shape.set_point_cloud(connected_polygon)
	return final_shape
