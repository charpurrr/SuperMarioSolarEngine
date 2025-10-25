class_name PushRays
extends Node2D
## Rays to check for pushable solid bodies.

@export var movement: PMovement

@export var body_catcher_r: Area2D

@onready var ray_r: RayCast2D = $PushRayR
@onready var ray_l: RayCast2D = $PushRayL

var pushing_object: RigidBody2D


func _physics_process(_delta: float) -> void:
	if is_colliding(true):
		for body in body_catcher_r.get_overlapping_bodies():
			if body is RigidBody2D and body.get_collision_layer_value(4):
				body.apply_force(Vector2.RIGHT * 1000)


func is_colliding(input_based: bool = false, collision_based: bool = false) -> bool:
	var check: int

	if input_based:
		check = InputManager.get_x_dir()
	elif not collision_based:
		check = movement.facing_direction
	else:
		check = get_collide_side()

	match check:
		1:
			return ray_r.is_colliding()
		-1:
			return ray_l.is_colliding()

	return false


## Return whichever wall is being colided with as an integer.
## This includes a priority-like system.
func get_collide_side() -> int:
	var left = ray_l.is_colliding()
	var right = ray_r.is_colliding()

	if not (left or right):
		return 0

	match InputManager.get_x_dir():
		1:
			if right:
				return 1
			else:
				return 0
		-1:
			if left:
				return -1
			else:
				return 0

	match movement.facing_direction:
		1:
			if right:
				return 1
		-1:
			if left:
				return -1

	if right:
		return 1
	elif left:
		return -1

	# Stop complaining.
	return 0
