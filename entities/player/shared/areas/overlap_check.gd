@tool
class_name OverlapDetection
extends Area2D
## Detect when the player is overlapping with something.
##
## This can be used to make the player respond to certain entities.

@export var player_hitbox: CollisionShape2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision_shape.position = player_hitbox.position
	collision_shape.shape.size = player_hitbox.shape.size
