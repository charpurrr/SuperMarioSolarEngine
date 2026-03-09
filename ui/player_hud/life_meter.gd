@tool
class_name LifeMeter
extends Control
## Small utility script that draws the proper visuals for
## the Life Meter based on the amount of HP the player has.

const ROTATION: float = TAU / 4

## Temporary max HP export variable for testing,
## realistically this is set within the Player scene.
@export var max_hp: int = 4:
	set(val):
		max_hp = clamp(val, 0, INF)
		hp = clamp(hp, 0, max_hp)

		queue_redraw()
@export var hp: int = max_hp:
	set(val):
		hp = clamp(val, 0, max_hp)

		if is_instance_valid(label):
			label.text = str(hp)

		queue_redraw()

@export var hit_shake_power: float = 6
@export_tool_button("Preview Hit", "Play")
var preview_action = take_hit.bind(0)

var is_shaking: bool = false

@export var low_health_sfx: AudioStream
@export var low_health_pulse_speed: float = 2.0
@export var low_health_pulse_amount: float = 0.2
@export var low_health_preview: bool = false:
	set(val):
		low_health_preview = val

		if val == true:
			is_pulsing = true
			hp = 1
			take_hit(0)
		else:
			is_pulsing = false
			hp = max_hp

var is_pulsing: bool = false:
	set(val):
		is_pulsing = val

		if val == false:
			scale = Vector2.ONE

@export_category("References")
@export var graphics: Control
@export var text: Control
@export var outline: Button 
@export var label: Label
@export var graphics_x_spring: DampedOscillator
@export var graphics_y_spring: DampedOscillator
@export var text_x_spring: DampedOscillator
@export var text_y_spring: DampedOscillator


func _draw() -> void:
	var center: Vector2 = size / 2 + Vector2(graphics_x_spring.displacement, graphics_y_spring.displacement)
	# A small margin is subtracted so the lines don't stick out
	# at the edges of the circle.
	var radius: float = outline.size.x / 2 - 0.2
	var step: float = TAU / max_hp

	# Only draw sectors if theres more than 0 HP.
	if hp > 0:
		_draw_sectors(center, radius, step)

	# No need to divide the life meter if there's only one hit point.
	if max_hp > 1:
		_draw_seperators(center, radius, step)


func _process(_delta: float) -> void:
	if is_pulsing:
		var sine: float = (
			1.0
			+ sin(Time.get_ticks_msec()
			/ 1000.0 * low_health_pulse_speed)
			* low_health_pulse_amount
		)

		scale = Vector2(sine, sine)

	if not is_shaking: return

	graphics.position = Vector2(graphics_x_spring.displacement, graphics_y_spring.displacement)
	text.position = Vector2(text_x_spring.displacement, text_y_spring.displacement)
	queue_redraw()

	if (
		is_zero_approx(graphics_x_spring.displacement) and
		is_zero_approx(graphics_y_spring.displacement) and 
		is_zero_approx(text_x_spring.displacement) and
		is_zero_approx(text_y_spring.displacement)
	):
		is_shaking = false
		graphics.position = Vector2.ZERO


func take_hit(amt: int, _type: HealthModule.DamageType = HealthModule.DamageType.GENERIC):
	hp -= amt

	if hp == 1:
		SFX.play_sfx(low_health_sfx, &"UI", self)
		is_pulsing = true
	else:
		is_pulsing = false

	shake(hit_shake_power)


func shake(power: float) -> void:
	var graphics_power_vec := Math.random_coord(power)
	var text_power_vec := Math.random_coord(power)

	graphics_x_spring.start(graphics_power_vec.x)
	graphics_y_spring.start(graphics_power_vec.y)
	text_x_spring.start(text_power_vec.x)
	text_y_spring.start(text_power_vec.y)

	is_shaking = true


func _draw_seperators(center: Vector2, radius: float, step: float) -> void:
	for i in range(max_hp):
		var angle: float = step * i - ROTATION

		draw_line(
			center,
			center + Vector2(cos(angle),sin(angle)) * radius,
			Color.BLACK,
			2,
		)


func _draw_sectors(center: Vector2, radius: float, step: float) -> void:
	_draw_circle_arc_poly(center, radius, 0, step * hp, _choose_slice_color(hp))


func _draw_circle_arc_poly(
		center: Vector2,
		radius: float,
		angle_from: float,
		angle_to: float,
		color: Color,
	) -> void:
	var nb_points: int = 32

	# Clamp to just under TAU to prevent first/last points overlapping
	var clamped_to: float = minf(angle_to, TAU - 0.0001)
	
	# Need at least ~2 degrees of arc or triangulation can fail
	if clamped_to - angle_from < 0.035:
		nb_points = 8

	var points_arc := PackedVector2Array()
	points_arc.append(center)

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (clamped_to - angle_from) / nb_points - PI / 2
		points_arc.append(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	draw_colored_polygon(points_arc, color)


func _choose_slice_color(slice: float) -> Color:
	var percentage: float = (slice / max_hp) * 100.0

	var thresholds: Array
	var colors: Array

	# Super Mario Galaxy's "Perfect Run" health meter.
	if max_hp == 1:
		thresholds = [100]
		colors = [Color.RED]
	elif max_hp == 2:
		thresholds = [50, 100]
		colors = [Color.RED, Color.AQUA]
	# Thresholds and associated colors if multiple of 3:
	elif max_hp % 3 == 0:
		thresholds = [100 * (1/3.0), 100 * (2/3.0), 100]  
		colors = [Color.RED, Color.YELLOW, Color.AQUA]
	# Thresholds and associated colors if multiple of 2:
	else:
		thresholds = [25, 50, 75, 100]
		colors = [Color.RED, Color.YELLOW, Color.GREEN, Color.AQUA]

	for i in range(thresholds.size()):
		if percentage <= thresholds[i]:
			return colors[i]

	# Fallback color (in case of unexpected values)
	return Color.WHITE
