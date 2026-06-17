@tool
class_name ComplexPreviewDisplayData
extends PreviewDisplayData
## A [PreviewDisplayData] that uses a scene to display the item.

## Scene used to display the item preview.
@export var preview_scene: PackedScene


func create() -> Node2D:
	return preview_scene.instantiate()
