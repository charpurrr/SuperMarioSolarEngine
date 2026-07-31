class_name Layer
extends SerializedResource
## A (parallax) layer of objects within an [Area].
## Z index is automatically handled by layer order, no manual z-ordering is required.

## The name of this layer.
@export var layer_name: StringName

#var objects: Dictionary[int, ObjectData] ## ID, ObjectData
## Modulate of the entire layer.
@export var tint: Color
## Scale of the entire layer.
@export var scale: Vector2
## The parallax ratio of the entire layer.
@export var parallax: Vector2

## Has no effect if left empty. If [member mission] is something specific, then
## the layer becomes a "mission layer" and will have the same Z index as the layer below it.
## If the current mission doesn't match up with the layer's [member mission], 
## the layer won't load in at all.
@export var mission: StringName


func serialize() -> String:
	return ""


func deserialize(_serialized_str: String) -> Error:
	return Error.ERR_UNCONFIGURED
