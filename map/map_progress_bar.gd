extends ProgressBar
var state = "Setup"
var time = 30
signal state_changed

func _process(delta: float) -> void:
	value += delta * (100/time)
	if value >= 100:
		change_state("Battle")
	queue_redraw()

func change_state(new_state):
	state = new_state
	value = 0
	time = 60
	get_parent().get_node("Label").text = new_state
	state_changed.emit(new_state)
	
