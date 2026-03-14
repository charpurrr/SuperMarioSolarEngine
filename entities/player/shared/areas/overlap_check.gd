@tool
class_name EnemyOverlapDetection
extends Area2D
## Detect when the player is overlapping with enemies.
##
## Note that this is NOT used to damage the player, as that is done by
## the [Enemy]'s hurt box. This [Area2D] only serves to detect overlap.

@export var player_hitbox: CollisionShape2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	collision_shape.position = player_hitbox.position
	collision_shape.shape.size = player_hitbox.shape.size
