extends Node

var moving_mode = "Direct"

func move_units_to(move_to):
	if moving_mode == "Direct":
		for unit in get_children():#
			unit.set_current_velocity(move_to)
			unit.set_moving(true)

func _on_line_pressed() -> void:
	moving_mode = "Line"

func _on_direct_pressed() -> void:
	moving_mode = "Direct"

func _on_keep_pressed() -> void:
	moving_mode = "Keep"
