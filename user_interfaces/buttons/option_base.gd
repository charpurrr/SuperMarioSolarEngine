@tool
@abstract
class_name OptionBase
extends UIButton

var setting: String:
	set(val):
		setting = val

		section = val.get_slice(" - ", 0)
		key = val.get_slice(" - ", 1)

var section: String
var key: String

## Variant typed so extended classes can set their own type.
var value: Variant = false


func _ready():
	if Engine.is_editor_hint():
		return

	super()

	LocalSettings.connect(&"setting_changed", update_value)

	# Initialise button
	var saved_val: Variant = LocalSettings.load_setting(section, key)
	update_value(key, saved_val)


func _unhandled_input(_event: InputEvent) -> void:
	if has_focus() and Input.is_action_just_pressed("setting_reset"):
		LocalSettings.change_setting(section, key, LocalSettings.defaults.get(key))
		avfx()


func update_value(changed_key: String, new_value: Variant = null):
	if changed_key != key:
		return

	value = new_value

	_update_button()


func change_setting(new_value):
	if setting.is_empty():
		return

	LocalSettings.change_setting(section, key, new_value)


func _get_property_list() -> Array[Dictionary]:
	if not Engine.is_editor_hint():
		return []

	var all_keys: PackedStringArray = []

	for sec in LocalSettings.settings:
		for k in LocalSettings.settings[sec]:
			all_keys.append("%s - %s" % [sec, k])

	return [
		{
			"name": "setting",
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_ENUM,
			"hint_string": ",".join(all_keys),
			"usage": PROPERTY_USAGE_DEFAULT,
		},
	]


## Overwritten by the parent class.[br]
## Defines how the option's text is displayed.
@abstract
func _update_button()
