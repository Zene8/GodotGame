extends Node2D

var selecting := false
var select_start := Vector2(0,0)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _process(delta: float) -> void:
	queue_redraw()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("L_click"):
		selecting = true
		select_start = get_global_mouse_position()
	
	if event.is_action_released("L_click"):
		selecting = false



func _draw() -> void:
	if selecting:
		var mousepos = get_global_mouse_position()
		var size = select_start - mousepos
		draw_rect(Rect2(mousepos,size),Color.BLUE,true)
