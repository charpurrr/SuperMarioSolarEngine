class_name LevelEditor
extends KeyScene
## Base class for the level editor.

@export var user_interface: LevelEditorUI
@export var quit_confirm: ConfirmationDialog
@export var spawn_point: AnimatedSprite2D
@export var selection_box: NinePatchRect
@export var level_preview: LevelPreview
@export var camera: Camera2D
@export var world_machine: WorldMachine
@export var player_scene: PackedScene


func _on_play_button_pressed() -> void:
	# TODO: A way to return to the editor (like backspace from og 63)
	user_interface.visible = false
	level_preview.visible = false
	spawn_point.visible = false

	var created_level = Level.new()

	# Turn all the preview objects into real stage props.
	for preview in level_preview.get_children():
		preview = preview as PreviewItem
		var data = preview.item_data
		if data is EditorItemDataActor:
			var inst = data.item_scene.instantiate()
			for property in data.properties:
				var prop_name = property.name
				assert(prop_name in inst)
				inst.set(prop_name, preview.property_values[prop_name])
			inst.position = preview.position
			created_level.add_child(inst)

	# Create the player node and place it in the level.
	var player_node = player_scene.instantiate()
	created_level.add_child(player_node)

	player_node.position = spawn_point.global_position
	created_level.player = player_node

	# Create a camera and parent it to the player.
	var cam = PlayerCamera.new()
	player_node.add_child(cam)
	created_level.camera = cam
	cam.enabled = true

	world_machine.handle_level_node(created_level, true)


func cursor_in_preview_field() -> bool:
	return user_interface.preview_detector.cursor_in_preview_field


func _on_transition_to(_handover: Variant) -> void:
	get_tree().set_auto_accept_quit(false)
	TransitionManager.greenlight_load_in()


func _on_transition_from() -> void:
	get_tree().set_auto_accept_quit(true)
