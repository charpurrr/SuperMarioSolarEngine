class_name LevelDesignerCamera
extends Camera2D
## Camera used in the Level Designer.

## The travelling speed of the camera. This is dynamic based on the [member zoom].
@export var cam_speed: float = 6.0
## How much [member cam_speed] gets multiplied when holding the [code]e_speed[/code] input.
@export var fast_cam_multiplier: float = 2.0

## The maximum zoom level.
@export_range(100, 100, 1.0, "or_greater", "hide_control", "suffix:%")
var zoom_max: int = 500
## The minimum zoom level.
@export_range(0, 100, 1.0, "hide_control", "suffix:%")
var zoom_min: int = 10
## The amount the zoom changes when pressing the zoom keys.
@export_range(0, 100, 1.0, "or_greater", "hide_control", "suffix:%")
var zoom_diff_keys: float = 5.0
## The amount the zoom changes when using the scrollwheel.
@export_range(0, 100, 1.0, "or_greater", "hide_control", "suffix:%")
var zoom_diff_scroll: float = 10.0

## The current camera zoom in percentage.[br]
## [b]Note[/b]: higher zoom percentage means you can see more level.
var zoom_percentage: float = 100.0:
	set(value):
		zoom_percentage = clamp(value, zoom_min, zoom_max)


func _physics_process(_delta: float) -> void:
	_handle_move()
	_handle_zoom()

	%Label.text = "position:%s \t zoom:%s" % [position, zoom]


func _handle_move() -> void:
	var input_vector: Vector2 = Input.get_vector(&"e_left", &"e_right", &"e_up", &"e_down")
	position += input_vector * _get_cam_speed()


## Return the appropriate camera speed depending on input.
## Holding the [code]e_speed[/code] input returns the standard
## [member cam_speed] multiplied by [member cam_s_multiplier].
## Otherwise, simply returns [member cam_speed].
func _get_cam_speed() -> float:
	var speed_zoom_ratio = cam_speed * (1 / zoom.x)

	if Input.is_action_pressed(&"e_speed"):
		return roundi(speed_zoom_ratio * fast_cam_multiplier)

	return speed_zoom_ratio


func _handle_zoom() -> void:
	if Input.is_action_pressed(&"camera_zoom_in"):
		_zoom(-zoom_diff_keys)

	if Input.is_action_pressed(&"camera_zoom_out"):
		_zoom(zoom_diff_keys)

	if Input.is_action_just_pressed(&"e_camera_zoom_in"):
		_zoom_at(-zoom_diff_scroll, get_global_mouse_position())

	if Input.is_action_just_pressed(&"e_camera_zoom_out"):
		_zoom_at(zoom_diff_scroll, get_global_mouse_position())


func _zoom(diff: float) -> void:
	zoom_percentage += diff

	var zoom_factor: float = 1 / (zoom_percentage / 100)
	zoom = Vector2.ONE * zoom_factor


## Zoom while keeping the world point currently under the cursor fixed on screen.
## [member position] and [member zoom] are derived from the camera itself rather
## than [method get_global_mouse_position], because this camera lives inside
## the grid canvaslayer and so its global mouse position is not affected by its 
## own zoom/pan.
func _zoom_at(diff: float, zoom_pos: Vector2) -> void:
	var viewport_center: Vector2 = get_viewport_rect().get_center()
	var cam_offset: Vector2 = zoom_pos - viewport_center

	# World pos under the cursor before zooming
	var world_pos: Vector2 = position + cam_offset / zoom
	_zoom(diff)

	# Re-anchor so that same world point stays under the cursor
	position = world_pos - cam_offset / zoom
