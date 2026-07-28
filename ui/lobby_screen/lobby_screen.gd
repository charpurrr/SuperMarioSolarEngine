class_name LobbyScreen
extends KeyScene
## The screen where you can create and join online lobbies to play together.

@export var lobby_entry: PackedScene

@export var lobby_list: VBoxContainer
@export var join_button: UIButton
@export var create_window: Window
@export var defocus: ColorRect

var selected_entry: Button


func _ready() -> void:
	super()

	LobbyDiscovery.lobbies_updated.connect(_refresh_lobby_list)
	LobbyDiscovery.start_listening()

	_refresh_lobby_list()

	join_button.toggle_disable(true)

	create_window.close_requested.connect(_hide_create_window)
	create_window.host_requested.connect(_hide_create_window.unbind(2))

	_hide_create_window()


func _show_create_window() -> void:
	defocus.show()
	create_window.show()


func _hide_create_window() -> void:
	defocus.hide()
	create_window.hide()


func _refresh_lobby_list() -> void:
	for child: Button in lobby_list.get_children():
		if not child.toggled.is_connected(_lobby_selected):
			child.toggled.connect(_lobby_selected.bind(child))

	#for child in lobby_list.get_children():
		#child.queue_free()
#
	#for key in LobbyDiscovery.discovered_lobbies.keys():
		#var info: Dictionary = LobbyDiscovery.discovered_lobbies[key]
		#var row: Button = lobby_entry.instantiate()
#
		#row.setup(info)
		#row.toggled.connect(_lobby_selected)
#
		#lobby_list.add_child(row)


func _lobby_selected(toggled_on: bool, lobby_button: Button) -> void:
	if selected_entry != lobby_button and selected_entry != null:
		selected_entry.button_pressed = false
		selected_entry = null

	if toggled_on:
		selected_entry = lobby_button
		join_button.toggle_disable(false)
	else:
		selected_entry = null
		join_button.toggle_disable(true)


func _on_create_pressed() -> void:
	_show_create_window()


func _on_join_pressed() -> void:
	pass
	#LobbyDiscovery.stop_listening()
	#NetworkManager.join_lobby(ip)


func _on_transition_to(_handover: Variant) -> void:
	TransitionManager.greenlight_load_in()


func _on_transition_from() -> void:
	LobbyDiscovery.stop_listening()
