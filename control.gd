extends Control
signal button_pressed



func _on_apply_button_pressed() -> void:
	print("apply button pressed")
	emit_signal("apply_button_pressed")


func _on_return_button_pressed() -> void:
	print("return button pressed")
	emit_signal("return_button_pressed")
