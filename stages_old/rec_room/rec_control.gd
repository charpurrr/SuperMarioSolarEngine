extends Control


@export var actor: Player

@export var camera: Camera2D
var locked: bool = true


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"rec_toggle_ui"):
		visible = !visible
	if Input.is_action_just_pressed(&"rec_pos_1"):
		actor.position.x = 73.0
	if Input.is_action_just_pressed(&"rec_pos_2"):
		actor.position.x = 336.0
	if Input.is_action_just_pressed(&"rec_pos_3"):
		actor.position.x = 601.0
	if Input.is_action_just_pressed(&"rec_lock_cam"):
		if locked:
			camera.reparent(actor)
			camera.position = Vector2(0.0, 0.0)
			locked = false
		else:
			camera.reparent(owner)
			camera.position = Vector2(337.0, 180.0)
			locked = true
	if Input.is_action_just_pressed(&"rec_flip"):
		actor.movement.update_direction(-actor.movement.facing_direction)
