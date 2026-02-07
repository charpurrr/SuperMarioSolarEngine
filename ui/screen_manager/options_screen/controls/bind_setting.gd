@tool
class_name BindSetting
extends HBoxContainer


@export_subgroup("Practical", "p_")
## The action name as defined in the project's [InputMap].
@export var p_action_name: StringName:
	set(val):
		p_action_name = val

		if not ProjectSettings.has_setting("input/" + val):
			push_warning("No action found in Project Settings matching: " + val)
		if is_instance_valid(bind_button):
			bind_button.action_name = val
## The type of InputEvents this bind button listens to.
## Simply add an unconfigured InputEvent of your desired type to the array
## to allow it to be parsed.
@export var p_parsable_events: Array[InputEvent]:
	set(val):
		p_parsable_events = val
		if is_instance_valid(bind_button):
			bind_button.parsable_events = val

@export_subgroup("Visuals", "vis_")
@export var vis_title: StringName:
	set(val):
		vis_title = val
		if is_instance_valid(label):
			label.text = val

@export var vis_animation: StringName:
	set(val):
		vis_animation = val
		if is_instance_valid(texture) and texture.sprites.has_animation(val):
			texture.animation = val
			texture.resume()

@export var vis_icon_flip_h: bool = false:
	set(val):
		vis_icon_flip_h = val
		if is_instance_valid(texture):
			texture.flip_h = val

@export var vis_icon_flip_v: bool = false:
	set(val):
		vis_icon_flip_v = val
		if is_instance_valid(texture):
			texture.flip_v = val

@export_category("References")
@export var texture: AnimatedTextureRect
@export var label: Label
@export var bind_button: UIBindButton
