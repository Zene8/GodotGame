extends Control

@onready var main_container = get_node("%MainMenuCont")
@onready var current_vbox = get_node("%MainMenuCont")
@onready var animation_player = get_node("CanvasLayer/AnimationPlayer")
@onready var OptionsContainer = get_node("%OptionContainer")
@onready var button = get_node("CanvasLayer/OptionContainer/Container/Apply_button")
@onready var button2 = get_node("CanvasLayer/OptionContainer/Container/Return_button")
@onready var GameList = get_node("%GameList")
@onready var lobby_scene = preload("res://Multiplayer/multiplayer.tscn")  # Load the lobby scene

	


func _ready():
	button.pressed.connect(_on_child_button_pressed)
	button2.pressed.connect(_on_child_button_pressed)
	OptionsContainer.visible = false
	GameList.visible = false
	main_container.get_node("Singleplayer").grab_focus()
	NetworkManager.connect("game_found", Callable(self, "update_game_list"))
	NetworkManager.discover_games()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_quit_confirmation()


func _on_multiplayer_pressed() -> void:
	slide_to("slide_to_multiplayer", %MultiplayerCont)




func _on_options_pressed() -> void:
	OptionsContainer.visible = true
	main_container.visible = false
	OptionsContainer.get_node("TabContainer/Video/Resolution_Optionbutton").grab_focus()


func _on_back_pressed()-> void:
	slide_to("slide_to_main", %MainMenuCont)

func _on_exit_pressed() -> void:
	show_quit_confirmation()
	
func _on_child_button_pressed()-> void:
	main_container.visible = true
	OptionsContainer.visible = false

func slide_to(animation_name, target_vbox):
	if current_vbox == target_vbox:
		return

	target_vbox.show()
	animation_player.play(animation_name)

	await animation_player.animation_finished

	if current_vbox:
		current_vbox.hide()
	current_vbox = target_vbox
	target_vbox.get_child(0).grab_focus()  # Focus on the first button in the target VBox

func show_quit_confirmation():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to quit the game?"
	confirmation_dialog.connect("confirmed", Callable(self, "_on_quit_confirmed"))
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()




func _on_quit_confirmed():
	get_tree().quit()




func _on_create_game_pressed() -> void:
	NetworkManager.host_game()  # Calls the host function from NetworkManager
	get_tree().change_scene_to_packed(lobby_scene)  # Switch to the lobby


func _on_join_game_pressed() -> void:
	GameList.visible = true 
	main_container.visible = false
