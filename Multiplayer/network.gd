extends Node



var udp_server = UDPServer.new()  # Use UDPServer for discovery
var peer = ENetMultiplayerPeer.new()

signal game_found(game_info)  # Signal when a game is found


const PORT = 135		# Game server port


# 🚀 Start hosting a game
func host_game():
	var error = peer.create_server(PORT, 6)
	if error != OK:
		print("❌ Server failed to start")
		return false
	else:
		multiplayer.multiplayer_peer = peer
		
		print("✅ Server running on port ", PORT)

		return true

func join_game():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
	print("joined")
	return true




func _on_disconnect_pressed() -> void:
	multiplayer.multiplayer_peer = null  # Disconnect from the server
	print("❌ Disconnected from the game")

	pass # Replace with function body.
