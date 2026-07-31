extends TabContainer

## The sound effect that plays when scrolling to the left.
@export var tab_left_sfx: SoundEffect
## The sound effect that plays when scrolling to the right.
@export var tab_right_sfx: SoundEffect
## The focus grabber for each tab.
## The array entry index should correspond to the index of the tab.
@export var focus_grabbers: Array[Control]


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"tab_left") and not current_tab == 0:
		current_tab -= 1
		tab_left_sfx.play(self)
		grab_focus_for_tab(current_tab)
	if Input.is_action_just_pressed(&"tab_right") and not current_tab == get_tab_count() - 1:
		current_tab += 1
		tab_right_sfx.play(self)
		grab_focus_for_tab(current_tab)


func grab_focus_for_tab(tab_idx: int) -> void:
	var control := focus_grabbers[tab_idx]
	if not is_instance_valid(control): return

	# Wait a frame so the tab can switch and enable before we try to grab focus.
	await get_tree().process_frame

	if control.focus_mode == FocusMode.FOCUS_NONE:
		for child in control.get_children():
			if child.focus_mode == FocusMode.FOCUS_ALL:
				child.grab_focus()
	else:
		control.grab_focus()
