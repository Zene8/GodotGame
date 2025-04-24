extends Node

var options_scene = preload("res://GUI/OptionsMenu.tscn")  # Path to your options scene
var options_instance = null  # Store the instance

func toggle_options():
	if options_instance:  # If the menu is open, close it
		options_instance.queue_free()
		options_instance = null
	else:  # Otherwise, open it
		var canvas_layer = get_tree().root.find_child("CanvasLayer", true, false)  # Find existing CanvasLayer
		if canvas_layer:
			options_instance = options_scene.instantiate()
			canvas_layer.add_child(options_instance)  # Add to CanvasLayer
			options_instance.set_process(true)

		else:
			print("❌ No CanvasLayer found in the scene!")
func _input(event):
	if event.is_action_pressed("ui_cancel"):  # "ui_cancel" is mapped to Esc by default
		print("esc pressed")
		toggle_options()
