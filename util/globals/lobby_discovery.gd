extends Node

signal lobbies_updated

const DISCOVERY_PORT: int = 7778
const BROADCAST_INTERVAL: float = 1.0
const LOBBY_TIMEOUT: float = 3.0

var broadcast_socket: PacketPeerUDP = PacketPeerUDP.new()
var listen_socket: PacketPeerUDP = PacketPeerUDP.new()
var is_broadcasting: bool = false
var is_listening: bool = false
var broadcast_timer: float = 0.0
var discovered_lobbies: Dictionary = {}  # String "ip:port": Dictionary info


func start_broadcasting() -> void:
	broadcast_socket.set_broadcast_enabled(true)
	broadcast_socket.set_dest_address("255.255.255.255", DISCOVERY_PORT)
	is_broadcasting = true


func stop_broadcasting() -> void:
	is_broadcasting = false


func start_listening() -> void:
	var error: int = listen_socket.bind(DISCOVERY_PORT)

	if error != OK:
		push_error("Failed to bind discovery listener: %s" % error)
		return

	is_listening = true
	discovered_lobbies.clear()


func stop_listening() -> void:
	is_listening = false
	listen_socket.close()


func _process(delta: float) -> void:
	if is_broadcasting:
		broadcast_timer += delta

		if broadcast_timer >= BROADCAST_INTERVAL:
			broadcast_timer = 0.0
			_send_broadcast()

	if is_listening:
		_poll_listener()
		_prune_stale_lobbies(delta)


func _send_broadcast() -> void:
	var info: Dictionary = {
		"name": NetworkManager.lobby_name,
		"current": NetworkManager.players.size(),
		"max": NetworkManager.max_players,
		"port": NetworkManager.GAME_PORT,
	}

	var json_string: String = JSON.stringify(info)

	broadcast_socket.put_packet(json_string.to_utf8_buffer())


func _poll_listener() -> void:
	while listen_socket.get_available_packet_count() > 0:
		var packet: PackedByteArray = listen_socket.get_packet()
		var sender_ip: String = listen_socket.get_packet_ip()
		var json_string: String = packet.get_string_from_utf8()

		var parsed = JSON.parse_string(json_string)

		if parsed == null:
			continue

		var info: Dictionary = parsed
		var key: String = "%s:%d" % [sender_ip, int(info.get("port", 0))]

		info["ip"] = sender_ip
		info["last_seen"] = 0.0

		discovered_lobbies[key] = info

	lobbies_updated.emit()


func _prune_stale_lobbies(delta: float) -> void:
	var keys_to_remove: Array = []

	for key in discovered_lobbies.keys():
		discovered_lobbies[key]["last_seen"] += delta

		if discovered_lobbies[key]["last_seen"] > LOBBY_TIMEOUT:
			keys_to_remove.append(key)

	for key in keys_to_remove:
		discovered_lobbies.erase(key)

	if keys_to_remove.size() > 0:
		lobbies_updated.emit()
