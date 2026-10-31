class_name PlayerSpawnPoint
extends Node2D
## The initial spawn point for the [Player] in the [Stage].
##
## Only one of these should exist at all times.
## If another [PlayerSpawnPoint] is found by the WorldMachine, it will be ignored.
## Only the first instance will be looked at.

## The state in which the player should start when spawned here.
## This name should correspond with the state's node name in the [Player] scene.
@export var starting_state: StringName

## The direction in which the player will face when spawned here.
@export_enum("Left", "Right") var starting_direction: int

## The player's starting velocity when spawned here.
@export var starting_velocity: Vector2


func _ready() -> void:
	add_to_group(&"player_spawn_points")
