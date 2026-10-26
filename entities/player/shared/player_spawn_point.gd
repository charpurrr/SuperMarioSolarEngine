class_name PlayerSpawnPoint
extends Node2D

## The state in which the player should start when spawned here.
## This name should correspond with the state's node name in the [Player] scene.
@export var starting_state: StringName

## The direction in which the player will face when spawned here.
@export_enum("Left", "Right") var starting_direction: int

## The player's starting velocity when spawned here.
@export var starting_velocity: Vector2
