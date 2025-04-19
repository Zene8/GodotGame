extends ProgressBar
var state = "Buy Phase"
var game_state = "Map"
var time = 15
var scene_manager
signal state_changed


func _process(delta: float) -> void:
	if game_state == "Map":
		value += delta * (100/time)
	if value >= 100:
		if state == "Buy Phase":
			change_state("Attack Phase")
		elif state == "Attack Phase":
			change_state("Buy Phase")
	queue_redraw()

func change_state(new_state):
	state = new_state
	value = 0
	if new_state == "Attack Phase":
		time = 5 #60
	elif new_state == "Buy Phase":
		time = 5 #15
	get_parent().get_node("Label").text = new_state
	state_changed.emit(new_state)
