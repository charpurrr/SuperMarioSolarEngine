extends Control


func _on_open_data_pressed() -> void:
	var path: String = ProjectSettings.globalize_path(LocalSettings.FILE_PATH)
	OS.shell_show_in_file_manager(path)
