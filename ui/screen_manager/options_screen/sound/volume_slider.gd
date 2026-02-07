@tool
extends UISlider

## Set in [VolumeSetting].
@onready var bus: AudioBus


func _ready() -> void:
	await owner.ready

	if not Engine.is_editor_hint():
		var saved_volume: float = LocalSettings.load_setting("Audio", bus.setting_name)
		slider.value = saved_volume * 100

		bus.bus_volume_updated.connect(_bus_updated)
	else:
		super()


func _try_sfx():
	# If not playing on ready, and no sound effects are 
	# playing in the UI audio bus:
	if get_tree().get_nodes_in_group(&"UI").is_empty():
		SFX.play_sfx(tick_sound, &"UI", self, linear_to_db(value / 100))


func _bus_updated(val):
	_update_slider(val * 100, false)
