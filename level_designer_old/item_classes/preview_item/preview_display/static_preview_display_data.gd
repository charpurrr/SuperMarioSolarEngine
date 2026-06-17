@tool
class_name StaticPreviewDisplayData
extends PreviewDisplayData
## A [PreviewDisplayData] that uses a static texture to display the item preview.

## Static texture used to display the preview.
@export var texture: Texture2D

## Selection shape of the preview.
@export var selection_shape: Shape2D


func create() -> Sprite2D:
	var inst = Sprite2D.new()
	inst.texture = texture
	return inst


func get_selection_shape() -> Shape2D:
	return selection_shape


func set_selection_shape(shape: Shape2D) -> void:
	selection_shape = shape


func needs_static_selection_shape() -> bool:
	return true


func get_reference_texture() -> Texture2D:
	return texture
