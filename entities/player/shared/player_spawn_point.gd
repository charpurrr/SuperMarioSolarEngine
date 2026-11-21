@tool
class_name PlayerSpawnPoint
extends Node2D
## The initial spawn point for the [Player] in the [Stage].
##
## Only one of these should exist at all times.
## If another [PlayerSpawnPoint] is found by the StageManager, it will be ignored.
## Only the first instance will be looked at.

@export var spawn_data: PlayerSpawnData
@export_group("Meta")
@export var hologram: Sprite2D


func _init() -> void:
	add_to_group(&"player_spawn_points")


func _ready() -> void:
	spawn_data.changed.connect(_spawn_data_changed)

	if not Engine.is_editor_hint():
		hologram.hide()


func _spawn_data_changed() -> void:
	hologram.position = spawn_data.offset
	hologram.flip_h = true if spawn_data.starting_direction == 0 else false
