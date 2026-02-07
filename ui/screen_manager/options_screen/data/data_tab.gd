extends Control

@export var data_label: RichTextLabel


func _ready() -> void:
	LocalSettings.setting_changed.connect(_setting_changed)
	_update_content()


func _setting_changed(_key: String, _value: Variant) -> void:
	_update_content()


func _update_content():
	data_label.text = LocalSettings.config.encode_to_text()


func _on_open_data_pressed() -> void:
	var path: String = ProjectSettings.globalize_path(LocalSettings.FILE_PATH)
	OS.shell_show_in_file_manager(path)
