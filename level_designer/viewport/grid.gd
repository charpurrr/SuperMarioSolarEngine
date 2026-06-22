@tool
extends Node2D

@export var grid_size: Vector2i = Vector2(32, 32)
@export var grid_color: Color = Color(1, 1, 1, 0.2)
@export var origin_color: Color = Color.BLACK


func _process(_delta) -> void:
	queue_redraw()


func _draw() -> void:
	var camera: Camera2D = get_viewport().get_camera_2d()

	if not camera:
		return

	var viewport_size: Vector2 = get_viewport_rect().size
	var zoom: Vector2 = camera.zoom
	var cam_pos: Vector2 = camera.get_screen_center_position()

	var half_view: Vector2 = (viewport_size / zoom) / 2.0
	var top_left: Vector2 = cam_pos - half_view
	var bottom_right: Vector2 = cam_pos + half_view

	draw_rect(get_viewport_rect(), Color.DARK_MAGENTA, false)
	draw_circle(top_left, 3.0, Color.MAGENTA)
	draw_circle(bottom_right, 3.0, Color.CYAN)

	var start_x: int = floor(top_left.x / grid_size.x) * grid_size.x
	var start_y: int = floor(top_left.y / grid_size.y) * grid_size.y

	var x: int = start_x

	for i in range(bottom_right.x / grid_size.x):
		draw_dashed_line(Vector2(x, top_left.y), Vector2(x, top_left.y), grid_color, 1.0 / zoom.x)
		x += grid_size.x
		#print("f (%f, %f) t (%f, %f)" % [x, top_left.y, x, top_left.y])

	var y: int = start_y

	for i in range(bottom_right.y / grid_size.y):
		draw_dashed_line(Vector2(top_left.x, y), Vector2(top_left.x, y), grid_color, 1.0 / zoom.x)
		y += grid_size.y

	#print("----------------------------------------")
