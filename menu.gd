extends Control

var current_vbox = null
var animation_player = null

func _ready():
	current_vbox = $VBoxContainerMain
	animation_player = $AnimationPlayer
	$VBoxContainer/Singleplayer.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_quit_confirmation()

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene("res://path_to_game_setup_scene.tscn")

func _on_multiplayer_pressed() -> void:
	slide_to("slide_to_multiplayer", $VBoxContainerMultiplayer)

func _on_options_pressed() -> void:
	slide_to("slide_to_options", $VBoxContainerOptions)

func slide_to(animation_name, target_vbox):
	if current_vbox == target_vbox:
		return

	target_vbox.rect_position.x = get_viewport().size.x
	target_vbox.show()

	animation_player.play(animation_name)

	await animation_player.animation_finished # Updated line

	current_vbox.hide()
	current_vbox = target_vbox

func _on_back_pressed():
	slide_to("slide_to_main", $VBoxContainerMain)

func _on_exit_pressed() -> void:
	show_quit_confirmation()

func show_quit_confirmation():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to quit the game?"
	confirmation_dialog.connect("confirmed", Callable(self, "_on_quit_confirmed"))
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()

func _on_quit_confirmed():
	get_tree().quit()
