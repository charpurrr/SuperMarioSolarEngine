extends Control

@export var vsync_button: OptionBool
@export var fps_cap_button: OptionEnum
@export var quality_button: OptionEnum


func _ready() -> void:
	LocalSettings.setting_changed.connect(_setting_changed)

	_on_vsync_update(LocalSettings.load_setting("General", "v_sync"))


func _setting_changed(key: String, value: Variant) -> void:
	if key == "v_sync":
		_on_vsync_update(value)


func _on_vsync_update(value: bool):
	# Disable the FPS cap button when V-Sync is enabled.
	fps_cap_button.toggle_disable(value)

	# Avoids focus neighboring issues in the UI when V-Sync is disabled.
	if value == true:
		vsync_button.focus_neighbor_right = quality_button.get_path()
		quality_button.focus_neighbor_left = vsync_button.get_path()
	else:
		vsync_button.focus_neighbor_right = fps_cap_button.get_path()
		quality_button.focus_neighbor_left = fps_cap_button.get_path()
