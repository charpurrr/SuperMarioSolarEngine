class_name AudioBus
extends RefCounted

signal bus_volume_updated(new_value)
signal bus_mute_updated(new_value)

var bus_name: StringName  # I.e. &"Master"
var setting_name: String  # I.e. "master_volume"

var bus_index: int

var default_db: float

var current_vol_linear: float

var muted: bool


func _init(new_bus_name: StringName, new_setting_name: String):
	setting_name = new_setting_name
	bus_name = new_bus_name

	var saved_linear: float = LocalSettings.load_setting("Audio", setting_name, 1.0)

	bus_index = AudioServer.get_bus_index(bus_name)

	default_db = AudioServer.get_bus_volume_db(bus_index)

	LocalSettings.setting_changed.connect(_setting_changed)
	update_volume(saved_linear)


func update_volume(new_vol_linear: float, no_signal: bool = false):
	current_vol_linear = new_vol_linear

	var db = linear_to_db(new_vol_linear)

	AudioServer.set_bus_volume_db(bus_index, db + default_db)

	if not no_signal:
		LocalSettings.change_setting("Audio", setting_name, new_vol_linear)


func update_mute(to: bool):
	muted = to
	AudioServer.set_bus_mute(bus_index, to)

	bus_mute_updated.emit(to)


func _setting_changed(key: String, value: Variant) -> void:
	if key == setting_name:
		update_volume(value, true)
		bus_volume_updated.emit(value)
