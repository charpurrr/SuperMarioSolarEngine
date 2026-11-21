class_name AreaTransition
extends Node2D

@export var destination_area_id: StringName
@export var destination_spawn: StringName


func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body is Player:
		return

	StageManager.current.change_area(
		destination_area_id,
		destination_spawn,
		SceneTransition.Type.CIRCLE,
		SceneTransition.Type.CIRCLE
	)
