class_name UIButton
extends Button
## A common UI button.

## Sound effect that plays when the button is pressed.
@export var press_sfx: SoundEffect
## Sound effect that plays when the button is focused.
@export var cursor_sfx: SoundEffect


func _ready() -> void:
	mouse_entered.connect(_try_grab_focus)
	mouse_exited.connect(_try_release_focus)
	pressed.connect(avfx)

	# Plays the cursor sound effect when focus is entered.
	focus_entered.connect(cursor_sfx.play.bind(self))


func _try_grab_focus():
	if not focus_mode == FOCUS_NONE:
		grab_focus()


func _try_release_focus():
	if has_focus():
		release_focus()


## The audio visual effects of a pause button.
func avfx() -> void:
	press_sfx.play(self)
	# Could optionally add visual effects too, I relied on the button themes instead.


## Toggle the disabled state of a button. If [code]force_to[/code] is set,
## forces the disabled state to whatever is defined.
## (Leave empty for normal toggling.)[br][br]
## For example: [code]toggle_disable(true)[/code] disables the button
## without minding its previous state.
func toggle_disable(force_to: Variant = null):
	if force_to == null:
		disabled = !disabled
	else:
		disabled = force_to

	if disabled:
		focus_mode = Control.FOCUS_NONE
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		modulate = Color.hex(0x323232ff)
	else:
		focus_mode = Control.FOCUS_ALL
		mouse_filter = Control.MOUSE_FILTER_STOP
		modulate = Color.WHITE
