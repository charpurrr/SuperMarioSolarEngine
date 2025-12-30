class_name Goomba
extends Enemy
## Goomba behaviour.

## Whether or not the Goomba will move around,
## searching for the player.
@export var stationary: bool = false
@export var gravity: float = 1

@export_category(&"References")
@export var hurtbox: Area2D

@export var ledge_ray_l: RayCast2D
@export var ledge_ray_r: RayCast2D
@export var wall_ray_l: RayCast2D
@export var wall_ray_r: RayCast2D

## The player that's being chased, if any.
var spotted_player: Player
## The difference in distance between the player, and the Goomba.
var diff: Vector2


func _physics_process(delta):
	super(delta)

	if is_instance_valid(spotted_player):
		diff = spotted_player.global_position - global_position


func take_hit(_source: Node, _damage_type: HealthModule.DamageType):
	pass


func die(source: Node, damage_type: HealthModule.DamageType):
	hurtbox.monitoring = false
	state_manager.set_to_state(&"Die", [source, damage_type])


func _on_hurtbox_body_entered(_body: Node2D) -> void:
	if spotted_player == null:
		return

	if (spotted_player.vel.y >= 0.0 or diff.y > 0.0):
		spotted_player.health_module.damage(self, HealthModule.DamageType.GENERIC, 1)
