extends Control

@export var data_peek: CodeEdit


func _ready() -> void:
	LocalSettings.setting_changed.connect(_update_content.unbind(2))
	_update_content()


func _update_content():
	data_peek.text = LocalSettings.config.encode_to_text()


func _on_open_data_pressed() -> void:
	var path: String = ProjectSettings.globalize_path(LocalSettings.FILE_PATH)
	OS.shell_show_in_file_manager(path)
