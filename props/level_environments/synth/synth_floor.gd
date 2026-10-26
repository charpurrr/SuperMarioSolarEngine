@tool
extends TextureRect

const LINE_H_COUNT: int = 16
const LINE_V_COUNT: int = 25

const LINE_H_EXP: float = 1.5

const LINE_WIDTH_PX: int = 2

@export_color_no_alpha var line_color: Color
@export var scroll_divisor: float = 8

var cam_x: float


func _physics_process(_delta):
	if !Engine.is_editor_hint():
		cam_x = -WorldMachine.camera.get_screen_center_position().x / scroll_divisor

	queue_redraw()


func _draw():
	_draw_horizontal_lines()
	_draw_vertical_lines()


func _draw_horizontal_lines():
	var progress: float = 0.0

	for i in LINE_H_COUNT:
		var line_h_pos_y: float = (pow(progress, LINE_H_EXP) 
		* size.y / pow(LINE_H_COUNT, LINE_H_EXP))

		draw_line(
			Vector2(0, line_h_pos_y + 0.5),
			Vector2(size.x, line_h_pos_y + 0.5),
			line_color,
			LINE_WIDTH_PX
		)

		progress += 1


func _draw_vertical_lines():
	var line_v_gap: float = size.x / LINE_V_COUNT

	for i in LINE_V_COUNT:
		var line_v_pos_x: float = line_v_gap * i + wrap(cam_x, 0.0, line_v_gap)

		draw_line(
			Vector2(line_v_pos_x, 0),
			Vector2(line_v_pos_x * 2 - size.x / 2, size.y),
			line_color,
			LINE_WIDTH_PX
		)
