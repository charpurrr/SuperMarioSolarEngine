@tool
class_name UISlider
extends Control
## A common UI slider.[br]


@export var max_value: float = 100.0:
	set(val):
		max_value = val

		if is_instance_valid(slider):
			slider.max_value = val
			_update_slider(value, false)
		if is_instance_valid(progress_bar):
			progress_bar.max_value = val

@export var value: float = 50.0:
	set(val):
		value = clampf(val, 0, max_value)
		if is_instance_valid(slider):
			slider.value = value
		if is_instance_valid(progress_bar):
			progress_bar.value = value
		if is_instance_valid(grabber) and grabber.is_inside_tree():
			grabber.set_anchor(SIDE_LEFT, value / max_value, true)
			grabber.set_anchor(SIDE_RIGHT, value / max_value, true)
		if is_instance_valid(outline) and outline.is_inside_tree():
			outline.set_anchor(SIDE_LEFT, value / max_value, true)
			outline.set_anchor(SIDE_RIGHT, value / max_value, true)

@export var default_value: float = 50

@export var slider_step: float = 1.0:
	set(val):
		slider_step = val

		if is_instance_valid(slider):
			slider.step = val

@export var disabled: bool = false:
	set(val):
		disabled = val

		if is_instance_valid(slider):
			_set_disable(disabled)

@export_category("References")
@export var slider: HSlider
@export var grabber: Control
@export var outline: Control
@export var progress_bar: ProgressBar
@export var tick_sound: SoundEffect

## Whether or not the slider is being hovered over / focused.
var hovering := false


func _ready() -> void:
	_update_slider(default_value, false)


func _process(_delta: float) -> void:
	var mouse_pos := get_global_mouse_position()

	hovering = (
		grabber.get_global_rect().has_point(mouse_pos) or
		slider.has_focus()
	)

	if hovering:
		grabber.modulate = Color("f1d937ff")
	else:
		grabber.modulate = Color.WHITE


## This function is called when the slider is moved,
## updating the visuals and optionally playing a sound effect.
func _update_slider(new_value: float, play_sfx: bool) -> void:
	value = new_value

	if play_sfx:
		_try_sfx()


## Tries to play the tick sound effect if the conditions are met.
func _try_sfx():
	# If not playing on ready, and no sound effects are 
	# playing in the UI audio bus:
	if get_tree().get_nodes_in_group(&"UI").is_empty():
		tick_sound.play(self)


func _set_disable(to: Variant = null):
	if to == true:
		focus_mode = Control.FOCUS_NONE
		modulate = Color.hex(0x323232ff)
	else:
		focus_mode = Control.FOCUS_ALL
		modulate = Color.WHITE

	slider.editable = !to
