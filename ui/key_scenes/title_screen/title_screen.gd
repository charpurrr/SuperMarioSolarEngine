class_name TitleScreen
extends KeyScene
## The opening title screen for the engine.

@export var anime: AnimationPlayer
@export var focus_grabber: UIButton

@export_category(&"Scenes")
@export_file("*.tscn") var wm_scene: String
@export_file("*.tscn") var editor_scene: String


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == &"start":
		anime.play(&"logo_float")
		focus_grabber.grab_focus()


func _on_play_pressed() -> void:
	TransitionManager.transition_scene(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(wm_scene)))


func _on_edit_pressed() -> void:
	TransitionManager.transition_scene(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(editor_scene)))


func _on_record_pressed() -> void:
	pass
	#TransitionManager.transition_scene(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(wm_scene)))


func _on_transition_to(_handover: Variant = null) -> void:
	pass


func _on_transition_from() -> void:
	pass
