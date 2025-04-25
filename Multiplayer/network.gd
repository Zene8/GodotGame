extends Node

# Autoload named NetworkManager
signal player_connected(peer_id, player_info)
signal player_disconnected(peer_id)
signal server_disconnected
signal player_list_updated


const PORT = 135
const DEFAULT_SERVER_IP = "127.0.0.1"
const MAX_CONNECTIONS = 20

# players will now hold both player info and color
var players = {}  # Structure: { peer_id: {info: player_info, color: player_color, score: 0} }
var player_info = {"Name": "Name"}
var players_loaded = 0
var peer = ENetMultiplayerPeer.new()

enum Owners { RED, BLUE, YELLOW, GREEN, PURPLE, ORANGE }
const OwnerColours = [
	Color(1, 0, 0, 0.7),    # RED
	Color(0, 0, 1, 0.7),    # BLUE
	Color(1, 1, 0.2, 0.7),  # YELLOW
	Color(0, 1, 0, 0.7),    # GREEN
	Color(1, 0, 1, 0.7),    # PURPLE
	Color(1, 0.4, 0.1, 0.7) # ORANGE
]

var available_colours = [Owners.RED, Owners.BLUE, Owners.YELLOW, Owners.GREEN, Owners.PURPLE, Owners.ORANGE]

@onready var mainMenu = preload("res://GUI/menu.tscn")

func _ready():
	randomize()
	multiplayer.peer_connected.connect(_on_player_connected)
	multiplayer.peer_disconnected.connect(_on_player_disconnected)
	multiplayer.connected_to_server.connect(_on_connected_ok)
	multiplayer.connection_failed.connect(_on_connected_fail)
	multiplayer.server_disconnected.connect(_on_server_disconnected)

# Host the game
func host_game():
	var error = peer.create_server(PORT, MAX_CONNECTIONS)
	if error:
		print("❌ Failed to start server: ", error)
		return error
	multiplayer.multiplayer_peer = peer
	print("✅ Server Running on Port", PORT)

	_on_player_connected(1)


# Join the game
func join_game(address = ""):
	if address.is_empty():
		address = DEFAULT_SERVER_IP
	var error = peer.create_client(address, PORT)
	if error:
		print("❌ Failed to connect to server: ", error)
		return error
	multiplayer.multiplayer_peer = peer

@rpc("call_local", "reliable")
func load_game(game_scene_path):
	get_tree().change_scene_to_file(game_scene_path)

@rpc("any_peer", "call_local", "reliable")
func player_loaded():
	if multiplayer.is_server():
		players_loaded += 1
		if players_loaded == players.size():
			$/root/Game.start_game()
			players_loaded = 0

func _on_player_connected(id):
	print("🔗 New player connected: ", id)
	if multiplayer.is_server():
		_register_player(id, player_info)  # Server registers the player
	else:
		print("❌ Non-server player cannot register player directly.")
	print("Players: ", players)

# Server-side player registration
@rpc("reliable")
func _register_player(player_id, new_player_info):
	if multiplayer.is_server():
		players[player_id] = {"info": new_player_info, "color": null , "score": 0}

		var assigned_color = assign_colour(player_id)
		if assigned_color != null:
			players[player_id]["color"] = assigned_color
			rpc_id(player_id, "set_player_color", assigned_color)
			print("🎨 Assigned color ", assigned_color, " to Player ", player_id)
		else:
			print("❌ No colors left to assign for Player ", player_id)

		broadcast_player_list()
		player_connected.emit(player_id, new_player_info)
		print("✅ Player ", player_id, " registered: ", new_player_info)

# Fix: send player list back to client instead of returning
@rpc("any_peer", "reliable", "call_local")
func request_full_player_list(target_id: int):
	if multiplayer.is_server():
		var player_data = {}
		var color_data = {}
		var score_data = {}
		for id in players.keys():
			player_data[id] = players[id]["info"]
			color_data[id] = players[id]["color"]
			score_data[id] = players[id]["score"]
		rpc_id(target_id, "receive_full_player_list", player_data, color_data, score_data)

# Client: Receive updated player list
@rpc("call_local", "reliable")
func receive_full_player_list(player_data, color_data, score_data):
	players.clear()
	for id in player_data.keys():
		players[int(id)] = {"info": player_data[id], "color": color_data[id], "score": score_data[id]}
	print("📋 Received full player list: ", players)

	player_list_updated.emit()


@rpc("call_local", "reliable")
func set_player_color(color_enum):
	var player_id = multiplayer.get_unique_id()
	if players.has(player_id):
		players[player_id]["color"] = color_enum
		print("🎨 Your assigned color is: ", color_enum)
	else:
		print("❌ Player ID ", player_id, " does not exist in players dictionary.")

func _on_player_disconnected(id):
	print("❌ Player disconnected: ", id)
	if players.has(id):
		players.erase(id)
		player_disconnected.emit(id)
		if multiplayer.is_server():
			release_colour(id)
			broadcast_player_list()
	else:
		print("❌ Tried to disconnect a player that wasn't found: ", id)

@rpc("reliable")
func broadcast_player_list():
	if multiplayer.is_server():
		var player_data = {}
		var color_data = {}
		for id in players.keys():
			player_data[id] = players[id]["info"]
			color_data[id] = players[id]["color"]
		rpc("receive_full_player_list", player_data, color_data)

func _on_connected_ok():
	var peer_id = multiplayer.get_unique_id()
	players[peer_id] = {"info": player_info, "color": null}
	player_connected.emit(peer_id, player_info)
	print("✅ Connected to server as ID: ", peer_id)

func _on_connected_fail():
	print("❌ Connection failed.")
	multiplayer.multiplayer_peer = null
	get_tree().change_scene_to_packed(mainMenu)
@rpc("any_peer", "call_local")

		
func _on_server_disconnected():
	print("❌ Server disconnected.")
	multiplayer.multiplayer_peer = null
	players.clear()
	server_disconnected.emit()
	get_tree().change_scene_to_packed(mainMenu)

func assign_colour(player_id):
	if available_colours.is_empty():
		return null
	var index = randi() % available_colours.size()
	var assigned_enum = available_colours[index]
	available_colours.remove_at(index)
	return assigned_enum

func release_colour(player_id):
	if players.has(player_id):
		var color = players[player_id]["color"]
		if color != null:
			available_colours.append(color)
		players[player_id]["color"] = null
	else:
		print("❌ Tried to release color for a player not found: ", player_id)

@rpc("call_local")
func start_minigame():
	print("Network manager executes start")
	get_tree().change_scene_to_file("res://SceneChanger/SceneChanger.tscn")
