extends Control

@onready var main_container = get_node("%MainMenuCont")
@onready var current_vbox = get_node("%MainMenuCont")
@onready var animation_player = get_node("AnimationPlayer")
@onready var OptionsContainer = get_node("OptionContainer")

func _ready():

	
	main_container.get_node("Singleplayer").grab_focus()


func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_quit_confirmation()

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene("res://path_to_game_setup_scene.tscn")

func _on_multiplayer_pressed() -> void:
	slide_to("slide_to_multiplayer", %MultiplayerCont)

func _on_options_pressed() -> void:
	OptionsContainer.visible = true
	#main_container.visible = false
	OptionsContainer.get_node("TabContainer/Video/Resolution_Optionbutton").grab_focus()



func _on_back_pressed()-> void:
	slide_to("slide_to_main", %MainMenuCont)

func _on_exit_pressed() -> void:
	show_quit_confirmation()



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
