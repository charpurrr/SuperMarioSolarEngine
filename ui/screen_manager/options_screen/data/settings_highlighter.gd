@tool
class_name SettingsHighlighter
extends SyntaxHighlighter
## Highlights the data from the [LocalSettings] config file.

@export var category_color: Color
@export var setting_color: Color
@export var symbol_color: Color
@export var function_color: Color
@export var number_color: Color
@export var boolean_color: Color
@export var string_color: Color
@export var string_name_color: Color


func _get_line_syntax_highlighting(line: int) -> Dictionary:
	var text: String = get_text_edit().get_line(line)
	var result: Dictionary = {}

	var trimmed: String = text.strip_edges()

	if trimmed.begins_with("["):
		result.set(0, {&"color": symbol_color})
		result.set(1, {"color": category_color})
		result.set(trimmed.length() - 1, {"color": symbol_color})
	else:
		var equals_idx: int = trimmed.find("=")
		var value_str: String = trimmed.substr(equals_idx + 1)

		result.set(0, {"color": setting_color})
		result.set(equals_idx, {"color": symbol_color})

		result.merge(_get_color_of_type(equals_idx + 1, value_str))

	return result


func _get_color_of_type(start_idx: int, value: String) -> Dictionary[int, Dictionary]:
	if value.contains('(') or value.contains('[') or value.contains('{'):
		return _get_colors_of_function(start_idx, value)
	elif value.is_valid_float() or value.is_valid_hex_number(true):
		return {start_idx: {"color": number_color}}
	elif value == "true" or value == "false":
		return {start_idx: {"color": boolean_color}}
	elif value.begins_with("\"") and value.ends_with("\""):
		return {start_idx: {"color": string_color}}
	elif value.begins_with("&\"") and value.ends_with("\""):
		return {start_idx: {"color": string_name_color}}
 
	# Default (error)
	return {start_idx: {"color": Color.RED}}


func _get_colors_of_function(start_idx: int, raw_value: String) -> Dictionary[int, Dictionary]:
	var result: Dictionary[int, Dictionary]

	var l_bracket_idx: int = -1
	var r_bracket_idx: int = -1

	# The indexes of the start and ending bracket of this function
	for i in range(0, raw_value.length()):
		if raw_value[i] in ['(', '[', '{'] and l_bracket_idx == -1:
			l_bracket_idx = i
		if raw_value[i] in [')', ']', '}']:
			r_bracket_idx = i

	# <<<func>>>(param_1, param_2)
	result.set(start_idx, {"color": function_color})

	# func<<<(>>>param_1, param_2)
	result.set(start_idx + l_bracket_idx, {"color": symbol_color})

	# func(<<<param_1>>>, <<<param_2>>>) -> [param_1, param_2]
	var content_regex := RegEx.create_from_string(r'(?<=([\(\[\{]|, ))[^, ]*(?=([\)\]\}]|,))')
	var content_array: Array[RegExMatch] = content_regex.search_all(raw_value)

	for entry in content_array:
		var entry_str: String = entry.get_string()
		var entry_idx: int = raw_value.find(entry_str) + start_idx
		var comma_idx: int = entry_idx + entry_str.length()

		# func(<<<param_1>>>, <<<param_2>>>)
		result.merge(_get_color_of_type(entry_idx, entry_str))

		# func(param_1 <<<,>>> param_2)
		if raw_value[comma_idx - start_idx] == ',':
			result.set(comma_idx, {"color": symbol_color})

	# func(param_1, param_2<<<)>>>
	result.set(start_idx + r_bracket_idx, {"color": symbol_color})
	result.set(start_idx + r_bracket_idx + 1, {"color": Color.WHITE})

	return result
