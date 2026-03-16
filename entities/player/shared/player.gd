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
@export var overlap_check: EnemyOverlapDetection
@export var auto_crouch_check: CrouchlockDetection

@export var dive_hurtbox: Area2D
@export var spin_hurtbox: Area2D
@export var crouch_spin_hurtbox: Area2D
@export var stomp_hurtbox: Area2D
@export var gp_hurtbox: Area2D

@onready var health_module := HealthModule.new(hp, take_hit, die, is_overlapping)

## This is set in [WorldMachine].
@onready var world_machine: WorldMachine
## This is set in [WorldMachine].
@onready var camera: PlayerCamera

var current_platform: MovingPlatform = null


func _ready():
	set_up_direction(Vector2.UP)


func _physics_process(_delta):
	move_and_slide()

	var new_platform: MovingPlatform = null

	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()

		if collider is AnimatableBody2D:
			var parent = collider.get_parent()
			if parent is MovingPlatform:
				new_platform = parent
				break

	if new_platform != current_platform:
		current_platform = new_platform

		if is_instance_valid(current_platform):
			current_platform.activate_by_player()


func take_hit(source: Node, damage_type: HealthModule.DamageType):
	state_manager.set_to_state(&"Hit", [source, damage_type, false])


func die(source: Node, damage_type: HealthModule.DamageType):
	state_manager.set_to_state(&"Hit", [source, damage_type, true])


func is_overlapping() -> bool:
	return overlap_check.has_overlapping_bodies()
