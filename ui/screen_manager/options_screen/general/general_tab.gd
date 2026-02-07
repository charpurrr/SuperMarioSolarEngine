extends Control

@export var fps_cap_button: OptionEnum


func _ready() -> void:
	LocalSettings.setting_changed.connect(_setting_changed)

	# Disable the FPS cap button when V Sync is enabled at startup
	fps_cap_button.toggle_disable(LocalSettings.load_setting("General", "v_sync"))


func _setting_changed(key: String, value: Variant) -> void:
	if key == "v_sync":
		fps_cap_button.toggle_disable(value)
