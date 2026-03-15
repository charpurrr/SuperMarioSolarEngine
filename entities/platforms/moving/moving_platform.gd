@tool
class_name MovingPlatform
extends Node2D
## Platform that moves across a set of points.

enum Behaviour {
	## The platform never moves.
	NONE,
	## The platform stops at the destination of its path.[br]
	## A → B → Stop[br]
	## B → A → Stop
	STOP_AT_END,
	## The platform returns to where it started from.[br]
	## A → B → A → Stop
	RETURN_TO_START,
	## The platform reappears at where it started from.[br]
	## A → B → Fade to A
	REAPPEAR_AT_START,
	## The platform never stops moving back and forth.[br]
	## A ⇄ B
	BACK_AND_FORTH,
	## The platform never stops moving in a loop.[br]
	## ↻ (A → B)
	LOOP,
}

enum PlatformState {
	## The platform is not moving.
	IDLE,
	## The platform is moving.
	MOVING,
	## The platform is fading out.
	FADING_OUT,
	## The platform is fading in.
	FADING_IN
}

## Whether or not the platform should start moving only when it touches the [Player].
@export var go_on_touch: bool = false
## How fast the platform moves across its path.
@export_range(0.0, 0.0, 0.005, "hide_control", "suffix:px/s", "or_greater", "or_less") \
var speed := 100.0
@export var speed_multiplier := Curve.new()
@export_range(0.01, 1.0) var fade_speed := 0.5
@export var behaviour := Behaviour.BACK_AND_FORTH
## The path the platform follows.
@export var points: PackedVector2Array:
	set(val):
		points = val

		if points.size() >= 2:
			_build_samples()

		direction = 1
		distance = 0.0

		if Engine.is_editor_hint():
			queue_redraw()
@export_range(0.0, 0.0, 0.005, "hide_control", "suffix:px", "or_greater", "or_less") \
var sample_spacing := 1.0
@export_tool_button("Start Preview", "Play") var start = _start
@export_category("References")
@export var platform_body: AnimatableBody2D
@export var platform_body_shape: CollisionShape2D
@export var platform_texture: NinePatchRect
@export var hologram: NinePatchRect
@export var player_detector_shape: CollisionShape2D

var target: Node
var target_sprite: NinePatchRect
var target_modulate: Color
var center := Vector2.ZERO

var samples: PackedVector2Array
var sample_distances: PackedFloat32Array
var total_length := 0.0

var distance := 0.0
var direction := 1
var progress := 0.0

var player: Player = null

var state := PlatformState.IDLE


func _ready() -> void:
	# Set manually so _physics_process() also runs within the editor.
	set_physics_process(true)

	if speed_multiplier.point_count == 0:
		speed_multiplier.add_point(Vector2(0, 1))
		speed_multiplier.add_point(Vector2(1, 1))

	target = platform_body
	target_sprite = platform_texture
	target_modulate = platform_texture.self_modulate

	if points.size() >= 2:
		_build_samples()

	platform_texture.resized.connect(_sync_shapes)

	if not Engine.is_editor_hint():
		hologram.queue_free()

		if not go_on_touch:
			state = PlatformState.MOVING
		return

	target = hologram
	target_sprite = hologram
	target_modulate = hologram.self_modulate
	center = platform_texture.position

	platform_texture.texture_changed.connect(_hologram_sync_visuals)
	platform_texture.resized.connect(_hologram_sync_visuals)
	_hologram_sync_visuals()

	if not points.is_empty():
		hologram.position = center

	state = PlatformState.MOVING


func _hologram_sync_visuals() -> void:
	hologram.texture = platform_texture.texture
	hologram.size = platform_texture.size
	center = platform_texture.position


func _sync_shapes() -> void:
	var half_length: float = platform_texture.size.x / 2
	platform_body_shape.shape.a.x = -half_length
	platform_body_shape.shape.b.x = half_length
	player_detector_shape.shape.size.x = platform_texture.size.x


func _draw() -> void:
	for point_idx in range(points.size() - 1):
		draw_dashed_line(points[point_idx], points[point_idx + 1], Color.WHITE, 2.0, 2.0)


func _physics_process(delta: float) -> void:
	_set_appropriate_state(delta)


func _set_appropriate_state(delta: float) -> void:
	match state:
		PlatformState.IDLE:
			return
		PlatformState.MOVING:
			_move_platform(delta)
		PlatformState.FADING_OUT:
			_fade_out()
		PlatformState.FADING_IN:
			_fade_in()


func _move_platform(delta: float) -> void:
	if not _should_move(): return

	progress = clampf(distance / total_length, 0.0, 1.0)

	var multiplier_sample := 1.0
	if speed_multiplier:
		multiplier_sample = speed_multiplier.sample(progress)

	distance += direction * speed * multiplier_sample * delta
	distance = clampf(distance, 0.0, total_length)

	match behaviour:
		Behaviour.STOP_AT_END:
			if (
				(direction == 1 and progress == 1.0) or
				(direction == -1 and progress == 0.0)
			):
				state = PlatformState.IDLE

		Behaviour.RETURN_TO_START:
			if direction == 1 and progress == 1.0:
				direction = -1
			elif direction == -1 and progress == 0.0:
				state = PlatformState.IDLE

		Behaviour.REAPPEAR_AT_START:
			if progress == 1.0:
				state = PlatformState.FADING_OUT

		Behaviour.LOOP:
			if progress == 1.0:
				distance = 0.0

		Behaviour.BACK_AND_FORTH:
			if progress == 0.0:
				direction = 1
			elif progress == 1.0:
				direction = -1

	target.position = _get_position(distance)


func _should_move() -> bool:
	if points.size() < 2:
		return false
	if behaviour == Behaviour.NONE:
		return false
	if go_on_touch and state != PlatformState.MOVING:
		return false

	return true


func _fade_out():
	direction = 0

	platform_body_shape.set_deferred(&"disabled", true)

	target_sprite.self_modulate = Math.lerp_colr(
		target_sprite.self_modulate,
		Color.TRANSPARENT,
		fade_speed,
		0.01
	)

	if target_sprite.self_modulate == Color.TRANSPARENT:
		target.position = points[0]
		state = PlatformState.FADING_IN


func _fade_in():
	platform_body_shape.set_deferred(&"disabled", false)

	target_sprite.self_modulate = Math.lerp_colr(
		target_sprite.self_modulate,
		target_modulate,
		fade_speed,
		0.01
	)

	if target_sprite.self_modulate == target_modulate:
		direction = 1
		distance = 0.0
		state = PlatformState.IDLE


func _build_samples() -> void:
	samples.clear()
	sample_distances.clear()

	total_length = 0.0

	for i in range(points.size() - 1):
		var a := points[i]
		var b := points[i + 1]

		var seg_len := a.distance_to(b)
		var dir := (b - a).normalized()

		var traveled := 0.0

		while traveled < seg_len:
			samples.append(a + dir * traveled)
			sample_distances.append(total_length + traveled)

			traveled += sample_spacing

		total_length += seg_len

	samples.append(points[-1])
	sample_distances.append(total_length)


func _get_position(dist: float) -> Vector2:
	var index := sample_distances.bsearch(dist)

	index = clampi(index - 1, 0, samples.size() - 2)

	var a_pos := samples[index]
	var b_pos := samples[index + 1]

	var a_dist := sample_distances[index]
	var b_dist := sample_distances[index + 1]

	var denom := b_dist - a_dist

	if is_zero_approx(absf(denom)):
		return a_pos

	var delta := (dist - a_dist) / denom
	return a_pos.lerp(b_pos, delta) + center


func _start() -> void:
	target.self_modulate = target_modulate

	if behaviour == Behaviour.STOP_AT_END and progress == 1.0:
		direction = -1
		hologram.position = points[-1]
	else:
		direction = 1
		hologram.position = points[0]
		distance = 0.0

	state = PlatformState.MOVING


func _on_player_detector_body_entered(body: Node2D) -> void:
	player = body

	if go_on_touch and state == PlatformState.IDLE:
		state = PlatformState.MOVING


func _on_player_detector_body_exited(_body: Node2D) -> void:
	player = null
