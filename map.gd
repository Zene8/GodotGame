extends Node2D

var selecting := false
var select_start := Vector2(0,0)
var select_area_shape = CollisionShape2D
var select_area = Area2D
var shifting = false
var moving := false
var moving_to = null
var moving_vector := 0.0
var moving_speed := 0.1 #defines the speed at which the units move
var moving_mode := "Direct"

func _ready() -> void:
	select_area_shape = $Area2D/CollisionShape2D
	select_area = $Area2D
	pass # Replace with function body.

func _process(_delta: float) -> void:
	queue_redraw()

func _physics_process(delta: float) -> void:
	if moving:
		moving_vector += delta * moving_speed
		if moving_mode == "Line":
			var n = 0
			for unit in $enemies.get_children():
				if unit.get("selected"):
					unit.position = unit.position.lerp(Vector2(moving_to.x, moving_to.y+n), moving_vector)
					n+=20
		elif moving_mode == "Direct":
			for unit in $enemies.get_children():
				if unit.get("selected"):
					unit.position = unit.position.lerp(Vector2(moving_to.x, moving_to.y), moving_vector)
		if moving_vector >= moving_speed:
			moving = false
			moving_vector = 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
		
	if event.is_action_pressed("L_click"):
		if !shifting:
			for unit in $enemies.get_children():
				if unit.get("selected"):
					unit.toggle_select()
		selecting = true
		select_start = get_global_mouse_position()
	
	if event.is_action_released("L_click"):
		selecting = false
		var mousepos = get_global_mouse_position()
		
		select_area_shape.position = Vector2(min(mousepos.x,select_start.x)+abs(select_start.x - mousepos.x)/2,min(mousepos.y,select_start.y)+abs(select_start.y - mousepos.y)/2)
		select_area_shape.shape.size = abs(select_start - mousepos)
		await get_tree().create_timer(0.1).timeout
		var areas = select_area.get_overlapping_areas()
		for area in areas:
			print(area)
			area.get_parent().toggle_select()
	
	if event.is_action_pressed("R_click"):
		if !moving:
			moving_to = get_global_mouse_position()
			for unit in $enemies.get_children():
				if unit.get("selected"):
					moving = true

func _draw() -> void:
	if selecting:
		var mousepos = get_global_mouse_position()
		var size = select_start - mousepos
		draw_rect(Rect2(mousepos,size),Color.BLACK,false)


func _on_move_line_pressed() -> void:
	moving_mode = "Line"

func _on_move_direct_pressed() -> void:
	moving_mode = "Direct"

func _on_move_keep_pressed() -> void:
	moving_mode = "Keep"
