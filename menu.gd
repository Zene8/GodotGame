extends Control

func _ready():
	$VBoxContainer/Singleplayer.grab_focus()

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		show_quit_confirmation()

func _on_singleplayer_pressed() -> void:
	get_tree().change_scene()

func _on_multiplayer_pressed() -> void:
	get_tree().change_scene()

func _on_options_pressed() -> void:
	var options = load("res://Menus/Options.tscn").instance()
	get_tree().current_scene.add_child(options)

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
