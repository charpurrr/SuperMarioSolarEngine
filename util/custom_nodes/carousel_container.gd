@tool
class_name CarouselContainer
extends Container
## A container that automatically arranges its children
## in a controllable carousel form.

## The minimum spacing between elements.
@export var spacing: float = 0.0

## Whether or not the selected index loops back around.
@export var loop: bool = false

## Whether or not the elements wrap around eachother in an elipse.
@export var wraparound: bool = false
## Radius of the wraparound elipse.
@export var wraparound_radius: float = 0.0
## Height of the wraparound elipse.
@export var wraparound_height: float = 0.0

## How transparent the elements near the selected element are.
@export_range(0.0, 1.0) var opacity_strength: float = 0.35
## How scaled the elements near the selected element are.
@export_range(0.0, 1.0) var scale_strength: float = 0.25
## The minimum scale percentage of an element.
@export_range(0.01, 0.99, 0.01) var scale_min: float = 0.1

## How fast the different lerps animate.
@export var lerp_speed: float = 6.5
## Which element is currently selected.
@export var selected_index: int = 0
## Whether or not the carousel follows the focused element.
@export var follow_focus: bool = false


func _process(delta: float) -> void:
	if get_child_count() == 0:
		return

	var children: Array[Node] = get_children()
	var child_count: int = children.size()

	if not loop:
		selected_index = clamp(selected_index, 0, child_count - 1)
	else:
		selected_index = wrapi(selected_index, 0, child_count)

	for i in child_count:
		var child: Control = children[i]

		if child.name == get_selected().name:
			_while_selected(child)
		else:
			_while_deselected(child)

		# SET POSITION
		if wraparound:
			var half: int = floor(child_count / 2.0)
			var relative_index: int = ((i - selected_index + half) % child_count) - half
			var angle: float = relative_index * (TAU / float(child_count))
			var x: float = sin(angle) * wraparound_radius
			var y: float = cos(angle) * wraparound_height
			var target_pos := Vector2(x, y - wraparound_height) - child.size / 2.0
			child.position = lerp(child.position, target_pos, lerp_speed * delta)
		else:
			var position_x: float = 0.0
			if i > 0:
				var prev: Control = children[i - 1]
				position_x = prev.position.x + prev.size.x + spacing
			child.position = Vector2(position_x, -child.size.y / 2.0)

		# SET SCALE
		child.pivot_offset = child.size / 2.0
		var target_scale: float = 1.0 - (scale_strength * abs(i - selected_index))
		target_scale = clamp(target_scale, scale_min, 1.0)
		child.scale = Math.lerp_vecr(child.scale, Vector2.ONE * target_scale, lerp_speed * delta, 0.01)

		# SET OPACITY
		var target_opacity: float = 1.0 - (opacity_strength * abs(i - selected_index))
		target_opacity = clamp(target_opacity, 0.0, 1.0)
		child.modulate.a = Math.lerp_fr(child.modulate.a, target_opacity, lerp_speed * delta, 0.01)

		# FOLLOW FOCUS
		if follow_focus and child.has_focus():
			selected_index = i


## Returns the currently selected node in the carousel.
func get_selected() -> Node:
	return get_child(selected_index)


## Extra definable logic for the selected element. Can be overridden by a child class.
func _while_selected(_selected_node: Node):
	pass


## Extra definable logic for the unselected elements. Can be overridden by a child class.
func _while_deselected(_deselected_node: Node):
	pass
