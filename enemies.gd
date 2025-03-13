extends Node

var moving_mode = "Direct"

func move_units_to(move_to):
	if moving_mode == "Direct":
		for unit in get_children():
			if unit.get("selected"):
				unit.set_current_velocity(move_to)
				unit.set_moving(true)
				unit.toggle_select()
	
	elif moving_mode == "Keep":
		#Find average position
		var unit_positions = Vector2(0, 0)
		for unit in get_children():
			unit_positions += unit.position
		var average_position = unit_positions/(get_children().size())
		for unit in get_children():
			if unit.get("selected"):
				unit.set_current_velocity(move_to + unit.position - average_position)
				unit.set_moving(true)
				unit.toggle_select()
	
	elif moving_mode == "Line":
		var offset = 0
		var location = -1 #0 for below, 1 for above
		for unit in get_children():
			if unit.get("selected"):
				unit.set_current_velocity(Vector2(move_to.x, move_to.y + offset*location))
				unit.set_moving(true)
				unit.toggle_select()
				if location == 1:
					location = -1
				else:
					location = 1
					offset += 20
				
func _on_line_pressed() -> void:
	moving_mode = "Line"

func _on_direct_pressed() -> void:
	moving_mode = "Direct"

func _on_keep_pressed() -> void:
	moving_mode = "Keep"
