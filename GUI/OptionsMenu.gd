extends Control

@onready var main_container = get_node("%mainPanel")
@onready var current_vbox = get_node("%mainPanel")
@onready var OptionsContainer = get_node("%SettingsContainer")
@onready var button = get_node("SettingsContainer/Container/Apply_button")
@onready var button2 = get_node("SettingsContainer/Container/Return_button")
@onready var Options = get_node(".")

	


func _ready():
	button.pressed.connect(_on_child_button_pressed)
	button2.pressed.connect(_on_child_button_pressed)
	OptionsContainer.visible = false
	main_container.get_node("Back").grab_focus()
	




func _on_child_button_pressed()-> void:
	main_container.visible = true
	OptionsContainer.visible = false


func show_quit_confirmation():
	var confirmation_dialog = ConfirmationDialog.new()
	confirmation_dialog.dialog_text = "Are you sure you want to quit the game?"
	confirmation_dialog.connect("confirmed", Callable(self, "_on_quit_confirmed"))
	add_child(confirmation_dialog)
	confirmation_dialog.popup_centered()




func _on_quit_confirmed():
	get_tree().quit()





func _on_settings_pressed() -> void:
	print('settings')
	OptionsContainer.visible = true
	main_container.visible = false
	OptionsContainer.get_node("TabContainer/Video/Resolution_Optionbutton").grab_focus()
	pass # Replace with function body.


func _on_quit_pressed() -> void:
	show_quit_confirmation()
	pass # Replace with function body.


func _on_back_pressed() -> void:
	visible = false 
	queue_free()  # Remove the options menu
	GlobalOptions.options_instance = null  # Reset the reference
	pass # Replace with function body.
