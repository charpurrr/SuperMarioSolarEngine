class_name MissionSelect
extends KeyScene
## The screen where you select which [Shine]
## you are planning to collect.[br][br]
## Note that which [Shine] you select can alter
## the level, spawn-position, or other things greatly.

@export var startup_sound: AudioStream

@export_file("*.tscn") var wm_scene: String


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("gui_accept"):
		TransitionManager.transition_scene(
			wm_scene,
			SceneTransition.Type.CIRCLE,
			SceneTransition.Type.CIRCLE
		)


func _on_transition_to(_handover: Variant) -> void:
	TransitionManager.greenlight_load_in()
	SFX.play_sfx(startup_sound, &"Music", self)


func _on_transition_from() -> void:
	pass
