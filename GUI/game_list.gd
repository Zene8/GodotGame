extends Control

@onready var game_list = $gameListCont  # VBoxContainer in UI

func _ready():
	NetworkManager.connect("game_found", Callable(self, "update_game_list"))
	NetworkManager.discover_games()

func update_game_list(game_info):
	var game_button = Button.new()
	game_button.text = game_info
	game_button.connect("pressed", Callable(self, "_on_game_selected").bind(game_info))
	game_list.add_child(game_button)

func _on_game_selected(game_info):
	var address = game_info.split("|")[1]
	NetworkManager.join_game()
