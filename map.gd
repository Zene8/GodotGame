extends Node2D

var selecting := false
var select_start := Vector2(0,0)
var select_area_shape = CollisionShape2D
var select_area = Area2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	select_area_shape = $Area2D/CollisionShape2D
	select_area = $Area2D
	pass # Replace with function body.

func _process(delta: float) -> void:
	queue_redraw()
	
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("L_click"):
		selecting = true
		select_start = get_global_mouse_position()
	
	if event.is_action_released("L_click"):
		selecting = false
		var mousepos = get_global_mouse_position()
		
		select_area_shape.position = Vector2(min(mousepos.x,select_start.x),min(mousepos.y,select_start.y))
		select_area_shape.shape.size = abs(select_start - mousepos)
		
		for area in select_area.get_overlapping_areas():
			print(area)
			area.get_parent().toggle_select()


func _draw() -> void:
	if selecting:
		var mousepos = get_global_mouse_position()
		var size = select_start - mousepos
		draw_rect(Rect2(mousepos,size),Color.BLUE,true)
