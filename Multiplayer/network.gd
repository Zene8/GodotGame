extends Node

var udp_server = UDPServer.new()  # Use UDPServer instead of PacketPeerUDP
const DISCOVERY_PORT = 7778  # Discovery port

signal game_found(game_info)  # Signal to update UI when a game is found

var peer = ENetMultiplayerPeer.new()
var udp_peer = PacketPeerUDP.new()
const PORT = 7777


# 🚀 Start hosting a game
func host_game():
	var error = peer.create_server(PORT, 32)
	if error != OK:
		print("❌ Server failed to start")
		return
	multiplayer.multiplayer_peer = peer
	print("✅ Server running on port ", PORT)

	# Start broadcasting to allow clients to discover this game
	start_broadcasting()

# 📡 Broadcast game presence every second
func start_broadcasting():
	udp_peer.set_broadcast_enabled(true)
	var game_info = "GameRoom|{ip}:{port}".format({"ip": get_local_ip(), "port": PORT})

	# Use a Timer instead of an infinite loop
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.autostart = true
	timer.connect("timeout", Callable(self, "_send_broadcast").bind(game_info))
	add_child(timer)

func _send_broadcast(game_info):
	udp_peer.put_packet(game_info.to_utf8_buffer())

# 🌍 Get local IP address (avoiding loopback)
func get_local_ip():
	for ip in IP.get_local_addresses():
		if !ip.begins_with("127"):  # Ignore loopback
			return ip
	return "0.0.0.0"  # Fallback

# 🔎 Start discovering games
func discover_games():
	udp_server.listen(DISCOVERY_PORT)
	print("🔎 Listening for games on port", DISCOVERY_PORT)
	
	while true:
		udp_server.poll()  # Process incoming packets
		if udp_server.is_connection_available():
			var udp_peer = udp_server.take_connection()
			var data = udp_peer.get_packet().get_string_from_utf8()
			print("Game found:", data)
			emit_signal("game_found", data)  # Signal to update UI
		await get_tree().create_timer(0.1).timeout  # Prevent infinite loop freeze
		
func _process(_delta):
	# Continuously check for new packets
	while udp_peer.get_available_packet_count() > 0:
		var data = udp_peer.get_packet().get_string_from_utf8()
		print("🎮 Found game:", data)
		emit_signal("game_found", data)  # Send data to UI

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
