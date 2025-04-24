extends Node

var player_scores = {}

func add_player(player_id):
	player_scores[player_id] = 0

func add_score(player_id):
	if player_id in player_scores:
		player_scores[player_id] += 1
		print("Player %s score: %d" % [player_id, player_scores[player_id]])

func reset_scores():
	player_scores.clear()
