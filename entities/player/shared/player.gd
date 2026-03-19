class_name Player
extends CharacterBody2D
## Playable 2D character.

@export var hp: int

@export_category(&"References")
@export var doll: AnimatedSprite2D
@export var fludd_f: AnimatedSprite2D
@export var fludd_b: AnimatedSprite2D

@export var state_manager: StateManager
@export var movement: PMovement
@export var input: InputManager

@export var push_rays: Node2D

@export var hitbox: CollisionShape2D
@export var dive_hitbox: CollisionShape2D
@export var small_hitbox: CollisionShape2D

@export var water_check: Area2D
@export var climb_check: Area2D
@export var overlap_check: OverlapDetection
@export var auto_crouch_check: CrouchlockDetection

@export var dive_hurtbox: Area2D
@export var spin_hurtbox: Area2D
@export var crouch_spin_hurtbox: Area2D
@export var stomp_hurtbox: Area2D
@export var gp_hurtbox: Area2D

@onready var health_module := HealthModule.new(hp, take_hit, die, is_overlapping_enemy)

## This is set in [WorldMachine].
@onready var world_machine: WorldMachine
## This is set in [WorldMachine].
@onready var camera: PlayerCamera

var current_pole: Pole = null


func _ready() -> void:
	set_up_direction(Vector2.UP)


func _physics_process(_delta) -> void:
	move_and_slide()

	# Activate MovingPlatforms
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		var parent: Node = collider.get_parent()

		if collider is AnimatableBody2D and parent is MovingPlatform:
			parent.activate_by_player()

	# Start Climbing
	if Input.is_action_just_pressed(&"up"):
		for area in climb_check.get_overlapping_areas():
			var parent := area.get_parent()
			if parent is Pole and not movement.is_submerged():
				state_manager.set_to_state(&"Climb", [area.position, parent.height])
				current_pole = parent


func take_hit(source: Node, damage_type: HealthModule.DamageType) -> void:
	state_manager.set_to_state(&"Hit", [source, damage_type, false])


func die(source: Node, damage_type: HealthModule.DamageType) -> void:
	state_manager.set_to_state(&"Hit", [source, damage_type, true])


func is_overlapping_enemy() -> bool:
	for body in overlap_check.get_overlapping_bodies():
		if body is Enemy:
			return true

	return false
