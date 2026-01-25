@tool
class_name ShineContainer
extends CarouselContainer
## Carousel container with some extra tweaks to work nicely for the mission select menu.

@export var scroll_sfx: AudioStreamWAV

## How many frames need to pass before you can scroll
## to the next shine when HOLDING left or right.
@export var scroll_hold_cooldown: int = 10
var scroll_timer: int = 0


func _ready() -> void:
	wraparound = get_child_count() > 2
	selected_index = 0


func _input(_event: InputEvent) -> void:
	if Input.is_action_pressed(&"right"):
		_scroll(1)
	elif Input.is_action_pressed(&"left"):
		_scroll(-1)
	else:
		scroll_timer = 0


func _scroll(difference: int):
	if scroll_timer == 0:
		scroll_timer = scroll_hold_cooldown

		SFX.play_sfx(scroll_sfx, &"UI", owner)
		selected_index += difference
	else:
		scroll_timer = max(scroll_timer - 1, 0)


func _while_selected(shine: Node):
	shine = shine as AnimatedTextureRect

	if not shine.playing:
		shine.play()


func _while_deselected(shine: Node):
	shine = shine as AnimatedTextureRect
	shine.stop()
