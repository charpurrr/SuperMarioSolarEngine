extends Window

signal host_requested(lobby_name: String, max_players: int)

@export var name_input: LineEdit
@export var player_count: SpinBox
@export var host_button: UIButton
@export var title_label: Label


func _ready() -> void:
	host_button.toggle_disable(true)
	name_input.text_changed.connect(_name_changed)


func _name_changed(new_text: String) -> void:
	if new_text != "":
		host_button.toggle_disable(false)
	else:
		host_button.toggle_disable(true)


func _on_host_pressed() -> void:
	var lobby_name: String = name_input.text
	var max_players: int = int(player_count.value)

	host_requested.emit(lobby_name, max_players)

	name_input.clear()
	player_count.value = player_count.min_value

	get_tree().call_group(&"lobby_selection_nodes", &"hide")
	get_tree().call_group(&"lobby_host_nodes", &"show")

	title_label.text = lobby_name
