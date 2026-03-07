@abstract
class_name Enemy
extends CharacterBody2D
## Abstract class for all enemies.

@export var hp: int

@export_category(&"References")
@export var hitbox: CollisionShape2D

@export var state_manager: StateManager

@export var anime: AnimationPlayer
@export var doll: AnimatedSprite2D

@onready var health_module := HealthModule.new(hp, take_hit, die)


func _ready():
	set_up_direction(Vector2.UP)


func _physics_process(_delta):
	move_and_slide()


## Behaviour for getting hit. (Gets overridden by child class.)
@abstract
func take_hit(_source: Node, _damage_type: HealthModule.DamageType)


## Behaviour for dying. (Gets overridden by child class.)
@abstract
func die(_source: Node, _damage_type: HealthModule.DamageType)
