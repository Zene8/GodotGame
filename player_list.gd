# PlayerList.gd
extends CanvasLayer

@onready var player_list = $PlayerList

func _process(delta):
	if Input.is_action_pressed("ui_tab"):
		visible = true
		update_player_list()
	else:
		visible = false

func update_player_list():
	player_list.clear()

	# Add all connected players
	for id in multiplayer.get_peers():
		if id == 1:
			player_list.add_item("Player " + str(id) + "(Host)")
		else:
			player_list.add_item("Player " + str(id))
		
	# Add local player
	if multiplayer.is_server():
		player_list.add_item("Host (You)")  # Server side
	else:
		player_list.add_item("You (Client)")  # Client side
