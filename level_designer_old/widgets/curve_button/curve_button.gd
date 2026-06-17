@tool
class_name CurveButton
extends DraggableButton
## An editor widget button meant for defining curve angles.

@export var button_l: DraggableButton
@export var button_r: DraggableButton
@export var handle_line: Line2D

var in_offset: Vector2
var out_offset: Vector2


func _input(event: InputEvent) -> void:
	super(event)

	# IN-handle
	if button_l.held_down:
		in_offset = button_l.position - position
		handle_line.set_point_position(0, button_l.position)
	# OUT-handle
	if button_r.held_down:
		out_offset = button_r.position - position
		handle_line.set_point_position(2, button_r.position)
