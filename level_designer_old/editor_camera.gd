class_name EditorCamera
extends Camera2D
## Camera used during level editing.

## The travelling speed of the camera.
@export var cam_speed: int = 10
## How much cam_speed gets multiplied when holding the e_speed input.
@export var cam_s_multiplier: float = 2.0


func _physics_process(_delta):
	_cam_movement()


## Moving the editor camera.
func _cam_movement():
	var input_vector: Vector2 = Input.get_vector("e_left", "e_right", "e_up", "e_down")

	position += input_vector * _get_cam_speed()


## Return the camera speed multiplier for _cam_movement().
func _get_cam_speed() -> int:
	if Input.is_action_pressed("e_speed"):
		return roundi(cam_speed * cam_s_multiplier)

	return cam_speed
