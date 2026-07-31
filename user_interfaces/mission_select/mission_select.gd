class_name MissionSelect
extends KeyScene
## The screen where you select which [Shine]
## you are planning to collect.[br][br]
## Note that which [Shine] you select can alter
## the level, spawn-position, or other things greatly.

@export var stage_info: StageInfo
@export var missions: Array[MissionInfo]

@export var startup_sound: SoundEffect

@export_file("*.tscn") var stage_manager: String


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed(&"gui_accept"):
		TransitionManager.transition_scene(
			stage_manager,
			SceneTransition.Type.CIRCLE,
			SceneTransition.Type.CIRCLE
		)


func _on_transition_to(_handover: Variant) -> void:
	

	TransitionManager.greenlight_load_in()
	startup_sound.play(self)


func _on_transition_from() -> void:
	pass
