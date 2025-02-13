extends Node2D

var MaxHealth := 100.0
var Health := 20.0:
	set(value):
		Health = clamp(value,0,MaxHealth)
var selected := false

func _draw() -> void:
	if selected:
		draw_circle(Vector2(0,0),10,Color.WHITE,true)
	draw_circle(Vector2(0,0),8,Color.RED,false,3)
	draw_arc(Vector2(0,0),8,PI*(1.0/2-Health/MaxHealth),PI*(1.0/2+Health/MaxHealth),6,Color.GREEN,3)
	
