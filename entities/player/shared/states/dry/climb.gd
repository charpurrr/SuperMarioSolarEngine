class_name Climb
extends PlayerState
## Climbing an object.

## List of possible directions to rotate through.
enum Direction {
	NONE = 0,
	LEFT = 1,
	BEHIND = 2,
	RIGHT = 3,
	INFRONT = 4,
}

## The currently active [enum Direction].
static var current_dir := Direction.NONE

## How fast the [Player] climbs up.
@export_range(0.0, 0.0, 1.0, 'hide_control', "or_greater", "suffix:px") \
var climb_up_distance := 100.0
@export_range(0.0, 0.0, 0.005, "hide_control", "or_greater", "suffix:px/s") \
var climb_up_speed := 100.0
@export_range(0.0, 0.0, 1.0, "hide_control", "or_greater", "suffix:frames") \
var climb_up_cooldown := 10
var climb_cooldown_timer: int = 0
## How fast the [Player] slides down.
@export_range(0.0, 0.0, 0.005, "hide_control", "or_greater", "suffix:px/s") \
var climb_down_speed := 150.0
## How quickly the [Player]'s [member position.x] lerps to the [Pole]'s [member position.x].
@export_range(0.0, 1.0, 0.01) var lineup_lerp_speed: float

@export var climb_sfx: SoundEffect

## The animation data for climbing [constant LEFT] or [constant RIGHT].
@export var climb_side_anim_data: PStateAnimData
## The animation data for climbing [constant BEHIND].
@export var climb_behind_anim_data: PStateAnimData
## The animation data for climbing [constant INFRONT].
@export var climb_infront_anim_data: PStateAnimData

## Whether or not the [Player] is climbing upwards.
var climbing := false
## Whether or not the [Player] is sliding downwards.
var sliding := false

## Upwards climbing tween.
var climb_tween: Tween
## The desired position after one "upwards climb cycle".
var target_pos_y: float
## The maximum position you can climb to. This is calculated from
## [code]Pole.position.y - height[/code]. 
var target_max_pos_y: float

## The [Pole]'s [member position], passed down from [method _on_enter].
var pos: Vector2
## The [Pole]'s [member height], passed down from [method _on_enter].
var height := 0.0


func _on_enter(params: Variant) -> void:
	pos = params[0]
	height = params[1]
	target_max_pos_y = params[0].y - (height / 2) - actor.climb_check.position.y

	actor.velocity = Vector2.ZERO

	target_pos_y = actor.position.y - actor.climb_check.position.y

	if current_dir == Direction.NONE or current_dir == Direction.LEFT or current_dir == Direction.RIGHT:
		if movement.facing_direction == 1:
			current_dir = Direction.LEFT
		else:
			current_dir = Direction.RIGHT


func _physics_tick(_delta: float) -> void:
	actor.position.x = Math.lerp_fr(actor.position.x, pos.x, lineup_lerp_speed, 0.01)
	actor.current_pole.z_index = -1

	# Left & Right
	if Input.is_action_just_pressed(&"right"):
		current_dir = wrapi(current_dir - 1, 1, 5) as Direction
		climb_sfx.play(actor)
	elif Input.is_action_just_pressed(&"left"):
		current_dir = wrapi(current_dir + 1, 1, 5) as Direction
		climb_sfx.play(actor)

	match current_dir:
		Direction.LEFT:
			movement.facing_direction = 1
			movement.update_direction(movement.facing_direction)
			overwrite_animation(climb_side_anim_data)
		Direction.BEHIND:
			actor.current_pole.z_index = 0
			overwrite_animation(climb_behind_anim_data)
		Direction.RIGHT:
			movement.facing_direction = -1
			movement.update_direction(movement.facing_direction)
			overwrite_animation(climb_side_anim_data)
		Direction.INFRONT:
			overwrite_animation(climb_infront_anim_data)

	# Up & Down
	climb_cooldown_timer = max(climb_cooldown_timer - 1, 0)

	if _can_climb():
		climb_sfx.play(actor)

		climbing = true
		climb_cooldown_timer = climb_up_cooldown

		actor.doll.frame = 1
		actor.velocity = Vector2.ZERO

		target_pos_y = clampf(actor.position.y - climb_up_distance, target_max_pos_y, INF)
	elif Input.is_action_pressed(&"down") and not climbing:
		actor.velocity.y = climb_down_speed
		sliding = true
	else:
		actor.velocity = Vector2.ZERO
		sliding = false

	if climbing and not climb_tween:
		actor.doll.play()

		climb_tween = create_tween()
		climb_tween.set_ease(Tween.EASE_IN)
		climb_tween.tween_property(
			actor,
			"position",
			Vector2(pos.x, target_pos_y),
			climb_up_distance / climb_up_speed
		)

		climb_tween.finished.connect(_end_climb)
	elif not climbing:
		actor.doll.frame = 0
		actor.doll.pause()
	elif not actor.climb_check.has_overlapping_areas():
		_end_climb()


func _can_climb() -> bool:
	return (
		Input.is_action_pressed(&"up") and
		not climbing and
		actor.climb_check.has_overlapping_areas()
		and climb_cooldown_timer == 0
	)


func _end_climb() -> void:
	climbing = false
	climb_tween.kill()
	climb_tween = null


func _on_exit() -> void:
	if climb_tween:
		_end_climb()

	sliding = false


func _trans_rules() -> Variant:
	if actor.position.y == target_max_pos_y:
		return [&"ClimbHandstand", [pos, height]]

	if sliding and actor.velocity.y > 0 and not actor.climb_check.has_overlapping_areas():
		return &"Airborne"

	if Input.is_action_just_pressed(&"jump"):
		if current_dir == Direction.LEFT or current_dir == Direction.RIGHT:
			return [&"Walljump", [-movement.facing_direction, false]]
		else:
			return [&"Walljump", [0, false]]

	return &""
