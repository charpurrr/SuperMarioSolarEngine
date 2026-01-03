extends KeyScene

@export var startup_sound: AudioStream


func _on_transition_to(_handover: Variant) -> void:
	SFX.play_sfx(startup_sound, &"Music", self)


func _on_transition_from() -> void:
	pass
