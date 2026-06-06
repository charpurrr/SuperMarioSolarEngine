class_name ScreenManager
extends Control
## Root node of a screen manager.
## Manages the transitions between different screens.

@export var color_blur: ColorRect
@export var anime_player: AnimationPlayer

@export_category("Screens")
## Exported node paths to the relevant screens.[br][br]
## Use a StringName to define a name, then a NodePath
## to define a reference for that screen.[br][br]
## You can then reference screens from across eachother by doing[br]
## [code]screen_manager.screens[name][/code].
@export var screens: Dictionary[StringName, NodePath]

## What screen is currently enabled.
var current_screen: Screen


func _ready() -> void:
	var pass_downs = {
		&"manager": self,
		&"ui": owner,
	}

	for child in get_children():
		if child is not Screen:
			continue

		for key in pass_downs:
			child.call_deferred(&"set", key, pass_downs[key])


## Leave "from" or "to" as null if wanting to transition out of or into gameplay.
func switch_screen(from: Screen = null, to: Screen = null) -> void:
#region FROM
	if from != null:
		if from.close_sfx:
			from.close_sfx.play(self)

		if from.close_anim == &"BACKWARDS":
			anime_player.play_backwards(from.open_anim)
		else:
			anime_player.play(from.close_anim)

		get_viewport().gui_release_focus()

		from.on_exit()

		await anime_player.animation_finished

		from.on_gone()
		from.visible = false
#endregion

#region TO
	if to == null:
		return

	if to.open_sfx:
		to.open_sfx.play(self)

	anime_player.play(to.open_anim)

	to.visible = true

	if to.focus_grabber:
		to.focus_grabber.grab_focus()

	to.on_load()

	await anime_player.animation_finished

	current_screen = to
	to.on_enter()
#endregion


## Returns the node reference of a screen as defined in the screens dictionary.
func get_screen(key: StringName):
	return get_node(screens[key])
