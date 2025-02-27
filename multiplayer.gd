extends Node

const PORT = 135

@export var player_scene: PackedScene

# Called when the host button is pressed to start the server.
func _on_host_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT, 6)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	
	# Assign the created server peer to Godot's networking system
	multiplayer.multiplayer_peer = peer
	
	# Connect the signals for when players connect or disconnect
	multiplayer.peer_connected.connect(_on_peer_connected)
	multiplayer.peer_disconnected.connect(_on_peer_disconnected)
	
	start_game()

# Called when a new player (peer) connects.
func _on_peer_connected(id):
	print("Player connected with id: %s" % id)
	var player = player_scene.instantiate()
	player.name = str(id)
	add_child(player)

# Called when a player disconnects.
func _on_peer_disconnected(id):
	print("Player disconnected with id: %s" % id)
	var player = get_node_or_null(str(id))
	if player:
		player.queue_free()

# Handling join as a client when a button is pressed.
func _on_join_pressed():
	var peer = ENetMultiplayerPeer.new()
	peer.create_client("localhost", PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer

# Alternative client join with specified remote address.
func _on_connect_pressed():
	var remote_address : String = $UI/Net/Options/Remote.text
	if remote_address == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(remote_address, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _ready():
	# Start with the game paused while the UI is up.
	get_tree().paused = true
	
	# Disable any unnecessary server relay data if not needed.
	multiplayer.server_relay = false
	
	# Automatically launch the server in headless mode.
	if DisplayServer.get_name() == "headless":
		print("Automatically starting dedicated server.")
		call_deferred("_on_host_pressed")

# Hides the UI and unpauses the game to start actual gameplay.
func start_game():
	$UI.hide()
	get_tree().paused = false
