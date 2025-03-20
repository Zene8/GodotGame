extends ProgressBar
var state = "Buy Phase"
var time = 15
signal state_changed

func _ready() -> void:
	state_changed.emit(state)
	
func _process(delta: float) -> void:
	value += delta * (100/time)
	if value >= 100:
		change_state("Attack Phase")
	queue_redraw()

func change_state(new_state):
	state = new_state
	value = 0
	time = 60
	get_parent().get_node("Label").text = new_state
	state_changed.emit(new_state)
