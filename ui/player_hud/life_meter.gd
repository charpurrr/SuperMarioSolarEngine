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

@export_category("References")
@export var outline: Button 
@export var label: Label


func _draw() -> void:
	var center: Vector2 = size / 2
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


func take_hit(amt: int, _type: HealthModule.DamageType):
	hp -= amt


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

	var points_arc := PackedVector2Array()
	points_arc.append(center)

	for i in range(nb_points + 1):
		var angle_point = angle_from + i * (angle_to - angle_from) / nb_points - PI / 2
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
