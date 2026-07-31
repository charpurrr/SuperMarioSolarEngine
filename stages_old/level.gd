class_name Level
extends Node2D

@export var level_name: StringName
@export var mission_name: StringName
@export_multiline var mission_info: String

@export var level_environment: PackedScene
@export var level_music: Resource

@export_category("References")
@export var player: CharacterBody2D
@export var camera: Camera2D
