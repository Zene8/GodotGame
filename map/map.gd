extends Node2D

var selecting := false
var select_start := Vector2(0,0)
var select_area_shape = CollisionShape2D
var select_area = Area2D
var shifting = false

func _ready() -> void:
	select_area_shape = $Area2D/CollisionShape2D
	select_area = $Area2D
	pass # Replace with function body.

func _process(_delta: float) -> void:
	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
		
	if event.is_action_pressed("L_click"):
		print(get_global_mouse_position())
		select_area_shape.disabled = false
		select_area_shape.position = get_global_mouse_position()
		select_area_shape.shape.size = Vector2(1, 1)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var areas = select_area.get_overlapping_areas()
		select_area_shape.disabled = true
		print(areas)
		if areas.size() >= 1:
			for area in areas:
				area.get_parent().toggle_select()
		else:
			for unit in $enemies.get_children():
				if unit.get("selected"):
					unit.toggle_select()

	if event.is_action_pressed("shift+L_click"):
		for unit in $enemies.get_children():
			if unit.get("selected"):
				unit.toggle_select()
		selecting = true
		select_start = get_global_mouse_position()

	if event.is_action_released("L_click") and Input.is_action_pressed("shift"):
		selecting = false
		var mousepos = get_global_mouse_position()
		
		select_area_shape.disabled = false
		select_area_shape.position = Vector2(min(mousepos.x,select_start.x)+abs(select_start.x - mousepos.x)/2,min(mousepos.y,select_start.y)+abs(select_start.y - mousepos.y)/2)
		select_area_shape.shape.size = abs(select_start - mousepos)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var areas = select_area.get_overlapping_areas()
		select_area_shape.disabled = true
		for area in areas:
			area.get_parent().toggle_select()
	
	if event.is_action_pressed("R_click"):
		$enemies.move_units_to(get_global_mouse_position())
		

func _draw() -> void:
	if selecting:
		var mousepos = get_global_mouse_position()
		var size = select_start - mousepos
		draw_rect(Rect2(mousepos,size),Color.BLACK,false)


func _on_keep_pressed() -> void:
	pass # Replace with function body.
