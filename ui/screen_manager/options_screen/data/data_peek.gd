class_name DataPeek
extends CodeEdit
# The DataPeek node allows you to view and edit your [LocalSettings]
# config file from within the game. This is useful for debugging purposes.

@export var data_debugger: CodeEdit

var has_errors: bool = false
var _ignore_external_changes: bool = true


func _ready() -> void:
	LocalSettings.setting_changed.connect(_update_content.unbind(2))
	_update_content()


func _update_content():
	if not _ignore_external_changes:
		text = LocalSettings.config.encode_to_text()


func _on_lines_edited_from(from_line: int, to_line: int) -> void:
	_ignore_external_changes = true

	for n in range(to_line - from_line + 1):
		set_line_background_color(from_line + n, Color(0, 0, 0, 0))
		data_debugger.text = ""
		has_errors = false

		var line_str: String = get_line(from_line + n)

		if line_str.is_empty(): continue

		# Editing category
		if line_str.begins_with("["):
			var category_name: String = line_str.substr(1, line_str.length() - 2)

			if category_name not in LocalSettings.settings.keys():
				_push_error(
					from_line + n,
					"Category \"%s\" not found in LocalSettings." % category_name
				)
		# Editing setting
		elif line_str.contains("="):
			var line_split: PackedStringArray = line_str.split("=")

			var setting_name: String = line_split[0]

			var setting_value: String = line_split[1]
			var value_type: int = typeof(str_to_var(setting_value))
			var value_default_type: int = typeof(LocalSettings.defaults.get(setting_name))

			if setting_name not in LocalSettings.defaults.keys():
				_push_error(
					from_line + n,
					"Setting \"%s\" not found in LocalSettings." % setting_name
				)
			elif value_type != value_default_type:
				_push_error(from_line + n,
					"Setting \"%s\" expects value of type %s, but got value of type %s." % 
					[
						setting_name,
						type_string(value_default_type),
						type_string(value_type)
					]
				)

			if not has_errors:
				LocalSettings.change_setting(
					LocalSettings.get_section(setting_name),
					setting_name,
					str_to_var(setting_value)
				)
		# Unrecognised
		else:
			_push_error(from_line + n, "Unrecognised input.")


func _push_error(line: int, msg: String):
	set_line_background_color(line, syntax_highlighter.critical_error_color)
	data_debugger.text = "@l%d: " % (line + 1) + msg
	has_errors = true
