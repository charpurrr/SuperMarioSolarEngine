extends Label

@onready var player: CharacterBody2D


func _physics_process(_delta):
	if is_instance_valid(owner.player):
		player = owner.player

	if player == null:
		return

	text = (
		"""FPS = %s \n
		is_on_floor() = %s
		can_air_action() = %s
		get_floor_angle / TAU = %.3f
		floor_incline = %.3f \n
		position.x = %.3f
		position.y = %.3f
		velocity.x = %.3f
		velocity.y = %.3f \n
		body_rotation = %.3f
		doll.frame = %d
		doll.offset = %s
		doll.rotation = %.3f
		facing = %d
		state = %s"""
		% [
			Engine.get_frames_per_second(),
			player.is_on_floor(),
			player.movement.can_air_action(),
			player.get_floor_angle() / TAU,
			player.movement.get_floor_incline(),
			player.global_position.x,
			player.global_position.y,
			player.velocity.x,
			player.velocity.y,
			player.movement.body_rotation,
			player.doll.frame,
			player.doll.offset,
			player.doll.rotation,
			player.movement.facing_direction,
			player.state_manager.get_leaf(),
		]
	)
