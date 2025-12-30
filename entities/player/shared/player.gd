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
@export var auto_crouch_check: CrouchlockDetection

@export var dive_hurtbox: Area2D
@export var spin_hurtbox: Area2D
@export var crouch_spin_hurtbox: Area2D
@export var stomp_hurtbox: Area2D
@export var gp_hurtbox: Area2D

@onready var health_module := HealthModule.new(hp, take_hit, die)

## This is set in [WorldMachine].
@onready var camera: PlayerCamera

## Current velocity.
var vel := Vector2.ZERO


func _ready():
	set_up_direction(Vector2.UP)


func _physics_process(delta):
	set_velocity(vel / delta)
	move_and_slide()

	vel = velocity * delta


func take_hit(_source: Node, _damage_type: HealthModule.DamageType):
	state_manager.set_to_state(&"Hit")


func die(_source: Node, _damage_type: HealthModule.DamageType):
	get_tree().call_deferred(&"reload_current_scene")
