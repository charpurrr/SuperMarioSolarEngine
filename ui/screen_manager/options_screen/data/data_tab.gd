extends Control

@export var category_color: Color
var category_hex: String:
	get(): return category_color.to_html(false)

@export var key_color: Color
var key_hex: String:
	get(): return key_color.to_html(false)

@export var bracket_color: Color
var bracket_hex: String:
	get(): return bracket_color.to_html(false)

@export_subgroup("Value Types", "v_")
@export var v_boolean: Color
var boolean_hex: String:
	get(): return v_boolean.to_html(false)

@export var v_number: Color
var number_hex: String:
	get(): return v_number.to_html(false)

@export var v_string: Color
var string_hex: String:
	get(): return v_string.to_html(false)

@export var v_class: Color
var class_hex: String:
	get(): return v_class.to_html(false)

@export_category("References")
@export var data_label: RichTextLabel


func _ready() -> void:
	LocalSettings.setting_changed.connect(_setting_changed)
	_update_content()


func _setting_changed(_key: String, _value: Variant) -> void:
	_update_content()


func _update_content():
	var raw_text = LocalSettings.config.encode_to_text()
	data_label.text = raw_text
	#data_label.text = _highlight_config(raw_text)


#func _highlight_config(text: String) -> String:
	#var lines: PackedStringArray = text.split("\n")
	#var result: String = ""
#
	#for line in lines:
		#if line.begins_with("["):
			#result += _highlight_section(line)
		#elif not line.is_empty():
			#result += _highlight_setting(line)
#
		#result += "\n"
#
	#return result
#
#
#func _highlight_section(line: String) -> String:
	#var section_name: String = line.substr(1, line.length() - 2)
#
	#return (
		#"[color=%s]" % bracket_hex + "[" + "[/color]" +
		#"[color=%s]" % category_hex + section_name + "[/color]" +
		#"[color=%s]" % bracket_hex + "]" + "[/color]"
	#)
#
#
#func _highlight_setting(line: String) -> String:
	#var equals_idx: int = line.find("=")
#
	#var key: String = line.substr(0, equals_idx)
#
	#var key_str: String = "[color=%s]" % key_hex + key + "[/color]" + "="
#
	#var value: String = line.substr(equals_idx + 1)
#
	#if value.contains("[") or value.contains("("):
		#var bracket_idx: int = value.find("[")
#
		#if bracket_idx == -1:
			#bracket_idx = value.find("(")
#
		#var class_str: String = value.substr(0, bracket_idx)
#
		#var content_str: String = value.substr(bracket_idx + 1, value.length() - class_str.length() - 2)
		#var content_array: PackedStringArray = content_str.split(", ")
		#var content_highlighted: String = ""
#
		#for entry in content_array:
			#content_highlighted += (
				#"[color=%s]" % _get_value_color(entry) +
				#entry + "[/color]" +
				#(", " if entry != content_array[content_array.size() - 1] else "")
			#)
#
		#return (
			#key_str +
			#"[color=%s]" % class_hex + class_str + "[/color]" +
			#"[color=%s]" % bracket_hex + value[bracket_idx] + "[/color]" +
			#"%s" % content_highlighted +
			#"[color=%s]" % bracket_hex + value[value.length() - 1] + "[/color]"
		#)
	#else:
		#return (
			#key_str +
			#"[color=%s]" % _get_value_color(value) + value + "[/color]"
		#)
#
#
#func _get_value_color(value: String) -> String:
	#if value == "true" or value == "false":
		#return boolean_hex
	#elif value.is_valid_int() or value.is_valid_float():
		#return number_hex
	#elif value.begins_with("\""):
		#return string_hex
#
	#return "ffffff"


func _on_open_data_pressed() -> void:
	var path: String = ProjectSettings.globalize_path(LocalSettings.FILE_PATH)
	OS.shell_show_in_file_manager(path)
