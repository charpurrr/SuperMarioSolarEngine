@tool
extends TextureRect

@export_color_no_alpha var line_color: Color
@export var line_h_count := 16
@export var line_v_count := 25
@export var line_h_exp := 1.5
@export var line_width := 2
@export var scroll_divisor: float = 8

var cam_x: float

@onready var environment: LevelEnvironment = owner


func _physics_process(_delta):
	if !Engine.is_editor_hint():
		cam_x = -environment.camera.get_screen_center_position().x / scroll_divisor
	
	queue_redraw()


func _draw():
	_draw_horizontal_lines()
	_draw_vertical_lines()


func _draw_horizontal_lines():
	var progress: float = 0.0

	for i in line_h_count:
		var line_h_pos_y: float = (pow(progress, line_h_exp) 
		* size.y / pow(line_h_count, line_h_exp))

		draw_line(
			Vector2(0, line_h_pos_y + 0.5),
			Vector2(size.x, line_h_pos_y + 0.5),
			line_color,
			line_width
		)

		progress += 1


func _draw_vertical_lines():
	var line_v_gap: float = size.x / line_v_count

	for i in line_v_count:
		var line_v_pos_x: float = line_v_gap * i + wrap(cam_x, 0.0, line_v_gap)

		draw_line(
			Vector2(line_v_pos_x, 0),
			Vector2(line_v_pos_x * 2 - size.x / 2, size.y),
			line_color,
			line_width
		)
