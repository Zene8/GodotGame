extends Node

var udp_server = UDPServer.new()  # Use UDPServer for discovery
const DISCOVERY_PORT = 7778  # Discovery port

signal game_found(game_info)  # Signal when a game is found

var peer = ENetMultiplayerPeer.new()
var udp_peer = PacketPeerUDP.new()
const PORT = 135		# Game server port


# 🚀 Start hosting a game
func host_game():
	var error = peer.create_server(PORT, 6)
	if error != OK:
		print("❌ Server failed to start")
		return
	multiplayer.multiplayer_peer = peer
	print("✅ Server running on port ", PORT)

	# Start broadcasting for game discovery
	start_broadcasting()


# 📡 Broadcast game presence every second
func start_broadcasting():
	udp_peer.set_broadcast_enabled(true)
	var game_info = "GameRoom|{ip}:{port}".format({"ip": get_local_ip(), "port": PORT})

	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_send_broadcast").bind(game_info))
	add_child(timer)
	timer.start()

func _send_broadcast(game_info):
	udp_peer.put_packet(game_info.to_utf8_buffer())


# 🌍 Get local IP address (avoiding loopback)
func get_local_ip():
	for ip in IP.get_local_addresses():
		if !ip.begins_with("127"):
			return ip
	return "0.0.0.0"  # Fallback


# 🔎 Discover available games
func discover_games():
	udp_server.listen(DISCOVERY_PORT)
	print("🔎 Listening for games on port", DISCOVERY_PORT)
	var timer = Timer.new()
	timer.wait_time = 0.1
	timer.connect("timeout", Callable(self, "_poll_udp_server"))
	add_child(timer)
	timer.start()

func _poll_udp_server():
	print("polling udp server")
	udp_server.poll()
	if udp_server.is_connection_available():
		var udp_peer = udp_server.take_connection()
		var data = udp_peer.get_packet().get_string_from_utf8()
		print("🎮 Game found:", data)
		emit_signal("game_found", data)


# 🔗 Join a discovered game
func join_game(address):
	var parts = address.split(":")
	if parts.size() != 2:
		print("❌ Invalid game address:", address)
		return

	var ip = parts[0]
	var port = int(parts[1])

	var client_peer = ENetMultiplayerPeer.new()
	var error = client_peer.create_client(ip, port)
	
	if error != OK:
		print("❌ Failed to join game at", address)
		return

	multiplayer.multiplayer_peer = client_peer
	print("✅ Joined game at ", address)
