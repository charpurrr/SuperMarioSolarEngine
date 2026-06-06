@tool
class_name Pole
extends Node2D
## Climbable pole object.

@export_range(1.0, 1.0, 1.0, "hide_control", "or_greater", "suffix:px") var height: int = 32:
	set(val):
		height = val

		if is_instance_valid(texture) and is_instance_valid(area):
			_set_height()
@export_category("References")
@export var texture: NinePatchRect
@export var area: Area2D
@export var collision_shape: CollisionShape2D


func _ready() -> void:
	_set_height()


func _set_height() -> void:
	# Area
	area.position.y = -height / 2.0
	collision_shape.shape.size.y = height

	# Texture
	texture.custom_minimum_size.y = height
