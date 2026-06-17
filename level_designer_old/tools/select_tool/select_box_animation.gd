class_name SelectionBox
extends NinePatchRect
## Object selector for the level designer.

## Area2D that handles item detection.
@export var selection_area: Area2D

## Collision shape for the selection.
@export var shape: CollisionShape2D

## Delay between animation steps in frames.
@export var animation_delay: int
@export var frame_count: int

var timer: float = 0


func _ready():
	timer = animation_delay


func _process(_delta):
	if visible == false:
		return

	timer = max(timer - 1, 0)

	if timer == 0:
		region_rect.position.x = wrap(
			region_rect.position.x + region_rect.size.x,
			0,
			frame_count * region_rect.size.x
		)

		timer = animation_delay
