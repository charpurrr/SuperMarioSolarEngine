extends Node

signal player_list_changed
#signal game_started_changed

const GAME_PORT: int = 7777

var peer: ENetMultiplayerPeer = ENetMultiplayerPeer.new()
var lobby_name: String = "Lobby"
var max_players: int = 4
var players: Dictionary = {}  # int peer_id: String player_name
var game_started: bool = false
var local_player_name: String = "Player"


func host_lobby(p_lobby_name: String, p_max_players: int) -> void:
	lobby_name = p_lobby_name
	max_players = p_max_players
	game_started = false
	players.clear()

	var error: int = peer.create_server(GAME_PORT, p_max_players)

	if error != OK:
		push_error("Failed to host: %s" % error)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)

	var my_id: int = multiplayer.get_unique_id()

	players[my_id] = local_player_name
	player_list_changed.emit()


func join_lobby(ip: String) -> void:
	var error: int = peer.create_client(ip, GAME_PORT)

	if error != OK:
		push_error("Failed to join: %s" % error)
		return

	multiplayer.multiplayer_peer = peer
	multiplayer.connected_to_server.connect(_on_connected_to_server)
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.server_disconnected.connect(_on_server_disconnected)


func _on_connected_to_server() -> void:
	var my_id: int = multiplayer.get_unique_id()
	_register_player.rpc_id(1, my_id, local_player_name)


func _on_connection_failed() -> void:
	push_error("Connection to lobby failed")


func _on_server_disconnected() -> void:
	push_warning("Host disconnected")

	players.clear()
	game_started = false
	player_list_changed.emit()


func _on_peer_connected(id: int) -> void:
	# Server side only: wait for _register_player RPC before adding to list.
	# If the game already started, get this late joiner straight into the level.
	if game_started:
		_send_late_join.rpc_id(id)

func _on_peer_disconnected(id: int) -> void:
	if players.has(id):
		players.erase(id)
		player_list_changed.emit()


@rpc("any_peer", "reliable")
func _register_player(id: int, player_name: String) -> void:
	if not multiplayer.is_server():
		return

	players[id] = player_name
	_sync_player_list.rpc(players)


@rpc("authority", "reliable", "call_local")
func _sync_player_list(new_players: Dictionary) -> void:
	players = new_players
	player_list_changed.emit()


func start_game(level_path: String) -> void:
	if not multiplayer.is_server():
		return

	game_started = true
	_load_level.rpc(level_path)


@rpc("authority", "reliable", "call_local")
func _load_level(level_path: String) -> void:
	game_started = true
	get_tree().change_scene_to_file(level_path)


@rpc("authority", "reliable")
func _send_late_join(_id: int) -> void:
	pass
	# Called only on the specific late-joining peer.
	#_load_level(GameState.current_level_path)
