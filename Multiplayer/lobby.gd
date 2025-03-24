extends Control

@onready var player_list = $PlayerList  # Assuming "PlayerList" is a UI List node

func _ready():
	update_player_list()
	multiplayer.peer_connected.connect(update_player_list)
	multiplayer.peer_disconnected.connect(update_player_list)

func update_player_list():
	player_list.clear()
	
	# Add all connected players
	for id in multiplayer.get_peers():
		player_list.add_item("Player " + str(id))  
	
	# Add host (server)
	if multiplayer.is_server():
		player_list.add_item("Host (You)")
