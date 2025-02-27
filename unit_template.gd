extends Node2D

var MaxHealth := 100.0
var Health := 100.0:
	set(value):
		Health = clamp(value,0,MaxHealth)
var selected := true
var shifting := false

func _process(delta: float) -> void:
	queue_redraw()
	
func _draw() -> void:
	if selected:
		draw_circle(Vector2(0,0),10,Color.WHITE,true)
	draw_circle(Vector2(0,0),8,Color.RED,false,3)
	draw_arc(Vector2(0,0),8,PI*(1.0/2-Health/MaxHealth),PI*(1.0/2+Health/MaxHealth),30,Color.GREEN,3)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
	
	if event.is_action_pressed("space") && selected:
		if shifting:
			Health += 10
		else:
			Health -= 10
	
func toggle_select():
	if selected:
		selected = false
	else:
		selected = true
