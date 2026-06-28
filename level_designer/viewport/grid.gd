class_name LDGrid
extends Control
## The background grid in the Level Designer.

@onready var mat: ShaderMaterial = material as ShaderMaterial


func _physics_process(_delta: float) -> void:
	var current_cam: Camera2D = get_viewport().get_camera_2d()

	mat.set_shader_parameter(&"camera_position", current_cam.position)
	mat.set_shader_parameter(&"camera_zoom", current_cam.zoom)
