extends CanvasLayer

@onready var player_list = $Panel/PlayerList  # Container for the list + button
var Owners = GameConstants.Owners       # Color enums
@onready var start_button = $Panel/StartGame  # Container for the list + button

func _ready() -> void:
	var is_lobby = get_tree().current_scene.name == "LobbyScene"
	visible = false
	NetworkManager.player_list_updated.connect(_on_player_list_updated)
	start_button.visible = is_lobby and multiplayer.is_server()
func _input(event):
	if event.is_action_pressed("ui_tab"):
		visible = true
		request_player_list_update()
	elif event.is_action_released("ui_tab"):
		visible = false

func request_player_list_update():
	if multiplayer.multiplayer_peer:
		var my_id = multiplayer.get_unique_id()
		NetworkManager.rpc_id(1, "request_full_player_list", my_id)

func _on_player_list_updated() -> void:
	# Detect if we're in the LobbyScene
	

	# Ensure a VBoxContainer exists for labels
	var vbox = player_list.get_node("VBoxContainer")
	if vbox == null:
		vbox = VBoxContainer.new()
		vbox.name = "VBoxContainer"
		player_list.add_child(vbox)

	# Clear out old labels
	for child in vbox.get_children():
		child.queue_free()

	# Rebuild the list
	for id in NetworkManager.players.keys():
		var data = NetworkManager.players[id]
		var info = data["info"]
		var color_enum = data["color"]
		var score = data.get("score", 0)
		var is_lobby = get_tree().current_scene.name == "LobbyScene"
		var player_name = info.get("Name", "Unknown")
		var label = Label.new()
		label.text = "Player %d: %s" % [id, player_name]

		if id == 1:
			label.text += " (Host)"
		if id == multiplayer.get_unique_id():
			label.text += " (You)"

		# Only in lobby: show their score
		if is_lobby:
			label.text += "  |  Score: %d" % score

		label.modulate = NetworkManager.OwnerColours[color_enum] \
			if color_enum != null else Color.WHITE
		vbox.add_child(label)


	# Fade-in effect
	player_list.modulate = Color(1, 1, 1, 0)
	player_list.show()
	player_list.create_tween()\
		.tween_property(player_list, "modulate:a", 1.0, 0.2)

	print("🖼️ Player list UI updated.")



func _on_start_game_pressed() -> void:
	print("🎮 Start Game button pressed!")
	# Ask server to actually start the minigame
	# (Requires a corresponding RPC on the server side)
	NetworkManager.rpc_id(1, "start_minigame")


func _on_disconnect_pressed() -> void:
	# 1) Close the network connection
	var peer = multiplayer.multiplayer_peer
	if peer:
		peer.close()
		multiplayer.multiplayer_peer = null

	# 2) Go back to the Main Menu
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")
