class_name QualityToggle
extends Node
## Stops the processing of its parent node when a specified quality is set.

## On what quality (or lower) the parent should stop being processed.
## For example, if [code]Medium[/code] is set as the value, the parent
## will also stop processing on [code]Low[/code] quality.
@export var stop_parent_on: GameState.Quality = GameState.Quality.LOW

@onready var parent: Node = get_parent()

@onready var stored_mode: Node.ProcessMode = parent.process_mode
@onready var stored_mat: Material = parent.material


func _ready() -> void:
	# Wait one process frame to ensure the QUALITY option has been loaded in..
	# This is done in the UserInterface's OptionsScreen which might be loaded
	# after this node, and thus not have quality initialised before
	# this _ready() runs.
	await get_tree().process_frame

	LocalSettings.setting_changed.connect(_setting_changed)
	_toggle_parent()


func _setting_changed(key: String, _value: Variant) -> void:
	if key == "quality":
		_toggle_parent()


func _toggle_parent() -> void:
	var current_quality: GameState.Quality = GameState.current_quality

	if current_quality <= stop_parent_on:
		stored_mode = parent.process_mode
		parent.process_mode = Node.PROCESS_MODE_DISABLED
		parent.visible = false

		if parent is CanvasItem:
			stored_mat = parent.material
			parent.material = null
	else:
		parent.process_mode = stored_mode
		parent.material = stored_mat
		parent.visible = true
