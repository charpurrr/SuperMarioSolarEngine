@tool
class_name FluddTank
extends Control
## Small utility script that draws the proper visuals for the Fludd Tank
## based on the amount of fuel the player has, and the container shape.

## Temporary max fuel export variable for testing,
## realistically this is set within the Player scene.
@export_range(0, 100, 0.01, "or_greater", "suffix:%")
var max_fuel: float = 100:
	set(val):
		max_fuel = val
		fuel = clamp(fuel, 0, max_fuel)
@export var fuel: float = 0:
	set(val):
		fuel = clamp(val, 0, max_fuel)

		if is_instance_valid(label):
			label.text = "%d%%" % fuel

		queue_redraw()

@export var fuel_t_color: Color
@export var fuel_l_color: Color
@export var fuel_r_color: Color

@export_category("References")
@export var label: Label
@export var container_l: Polygon2D
@export var container_r: Polygon2D
@export var container_t: Polygon2D
@export var container_b: Polygon2D

## Height of the container calculated by the difference between
## the bottom container polygon and the top container polygon
var container_height: float


func _ready() -> void:
	container_height = container_t.polygon[2].y - container_b.polygon[2].y

	fuel = FluddManager.fuel


func _draw() -> void:
	# ORDER OF CONTAINER PANEL POLYGON POINTS MATTER!
	# These calculations ASSUME the following:
	# - Point 0 is always the top left point of the side panel container polygons.
	# - Point 1 is always the top right point of the side panel container polygons.
	# - Point 2 is always the bottom right point of the side panel container polygons.
	# - Point 3 is always the bottom left point of the side panel container polygons.

	if fuel == 0:
		return

	var top_poly: PackedVector2Array
	var left_poly: PackedVector2Array
	var right_poly: PackedVector2Array

	var y_offset: Vector2 = Vector2(0, container_height * (1 - (fuel / max_fuel)))

	# Offset all points by y-offset for the top polygon.
	for point: Vector2 in container_t.polygon:
		top_poly.append(point - y_offset)

	left_poly.append(container_l.polygon[0] - y_offset) # TOP-LEFT
	left_poly.append(container_l.polygon[1] - y_offset) # TOP-RIGHT
	left_poly.append(container_l.polygon[2]) # BOTTOM-LEFT
	left_poly.append(container_l.polygon[3]) # BOTTOM-RIGHT

	right_poly.append(container_r.polygon[0] - y_offset) # TOP-LEFT
	right_poly.append(container_r.polygon[1] - y_offset) # TOP-RIGHT
	right_poly.append(container_r.polygon[2]) # BOTTOM-LEFT
	right_poly.append(container_r.polygon[3]) # BOTTOM-RIGHT

	draw_colored_polygon(top_poly, fuel_t_color)
	draw_colored_polygon(left_poly, fuel_l_color)
	draw_colored_polygon(right_poly, fuel_r_color)


func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return

	if Input.is_action_pressed(&"use_fludd"):
		fuel = FluddManager.fuel
