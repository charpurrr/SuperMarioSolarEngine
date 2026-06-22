class_name LevelDesignerCamera
extends Camera2D
## Camera used in the Level Designer.

## The travelling speed of the camera. This is dynamic based on the [member zoom].
@export var cam_speed: float = 10
## How much [member cam_speed] gets multiplied when holding the [code]e_speed[/code] input.
@export var cam_s_multiplier: float = 2.0

@export_range(100, 100, 1.0, "or_greater", "hide_control", "suffix:%")
var zoom_max: int = 1000
@export_range(0, 100, 1.0, "hide_control", "suffix:%")
var zoom_min: int = 10
@export_range(0, 100, 1.0, "or_greater", "hide_control", "suffix:%/s")
var zoom_diff: float = 5.0
@export_range(0, 1, 0.01)
var zoom_interp_weight: float = 0.2

## The current camera zoom in percentage.[br]
## [b]Note[/b]: higher zoom percentage means you can see more level.
var zoom_percentage: float = 100.0

## The zoom value the camera gets tweened to.
var target_zoom: float = 100.0


func _physics_process(delta: float) -> void:
	_handle_move(delta)
	_handle_zoom(delta)


func _handle_move(_delta: float) -> void:
	var input_vector: Vector2 = Input.get_vector("e_left", "e_right", "e_up", "e_down")
	position += input_vector * _get_cam_speed()


## Return the appropriate camera speed depending on input.
## Holding the [code]e_speed[/code] input returns the standard
## [member cam_speed] multiplied by [member cam_s_multiplier].
## Otherwise, simply returns [member cam_speed].
func _get_cam_speed() -> float:
	if Input.is_action_pressed("e_speed"):
		return roundi(cam_speed * cam_s_multiplier)

	return cam_speed


func _handle_zoom(_delta: float) -> void:
	if Input.is_action_pressed(&"camera_zoom_in"):
		target_zoom -= zoom_diff

	if Input.is_action_pressed(&"camera_zoom_out"):
		target_zoom += zoom_diff

	target_zoom = clamp(target_zoom, zoom_min, zoom_max)
	zoom_percentage = lerpf(zoom_percentage, target_zoom, zoom_interp_weight)

	var zoom_factor: float = 1 / (zoom_percentage / 100)
	zoom = Vector2(zoom_factor, zoom_factor)
