extends Node
##############MULTIPLAYER SHENANIGANS HERE#####################

#great code theo
var peer = ENetMultiplayerPeer.new()
@export var player_scene: PackedScene

#Ran if the host button is pressed
func _on_host_pressed():
	peer.create_server(135, 6)
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_disconnected.connect(_add_player)

func _add_player(id = 1):
	var player = player_scene.instantiate()
	player.name = str(id)

func _on_join_pressed():
	peer.create_client("localhost", 135)
	multiplayer.multiplayer_peer = peer
