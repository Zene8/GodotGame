extends Node2D

var selecting := false
var select_start := Vector2(0,0)
var select_area_shape = CollisionShape2D
var select_area = Area2D
var shifting = false
var dragging_unit = false
var selecting_unit = null
var selecting_unit_colour = null
var button_vals = {"BaseUnit":{"button":Button, "val":10}, "Tank":{"button":Button, "val":5}, "Sniper":{"button":Button, "val":5}}

func _ready() -> void:
	select_area_shape = $Area2D/CollisionShape2D
	select_area = $Area2D
	button_vals["BaseUnit"].button = $CanvasLayer/UnitButtons/HBoxContainer/BaseUnit
	button_vals["Tank"].button = $CanvasLayer/UnitButtons/HBoxContainer/Tank
	button_vals["Sniper"].button = $CanvasLayer/UnitButtons/HBoxContainer/Sniper
	button_vals["BaseUnit"].button.text = str(button_vals["BaseUnit"].val)
	button_vals["Tank"].button.text = str(button_vals["Tank"].val)
	button_vals["Sniper"].button.text = str(button_vals["Sniper"].val)

func _process(_delta: float) -> void:
	if dragging_unit:
		var mousepos = get_global_mouse_position()
		selecting_unit.position = mousepos

	queue_redraw()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
		
	if event.is_action_pressed("L_click") and not dragging_unit:
		select_area_shape.disabled = false
		select_area_shape.position = get_global_mouse_position()
		select_area_shape.shape.size = Vector2(1, 1)
		await get_tree().physics_frame
		await get_tree().physics_frame
		var areas = select_area.get_overlapping_areas()
		if areas.size() >= 1:
			for area in areas:
				area.get_parent().toggle_select()
		else:
			for unit in $Player1.get_children():
				if unit.get("selected"):
					unit.toggle_select()

	if event.is_action_pressed("shift+L_click"):
		for unit in $Player1.get_children():
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
			
	if event.is_action_pressed("L_click") and dragging_unit:
		if selecting_unit.get_node("Area2D").get_overlapping_areas().size() == 0 and button_vals[dragging_unit].val > 0:
			button_vals[dragging_unit].val -= 1
			button_vals[dragging_unit].button.text = str(button_vals[dragging_unit].val)
			var placed_unit = null
			if dragging_unit == "BaseUnit":
				placed_unit = preload("res://units/unit_template/unit_template.tscn").instantiate()
			elif dragging_unit == "Tank":
				placed_unit = preload("res://units/tank_template/tank_template.tscn").instantiate()
			elif dragging_unit == "Sniper":
				placed_unit = preload("res://units/sniper_template/sniper_template.tscn").instantiate()
			$Player1.add_child(placed_unit)
			placed_unit.position = selecting_unit.position
	
	if event.is_action_pressed("R_click"):
		$Player1.move_units_to(get_global_mouse_position())
		

func _draw() -> void:
	if selecting:
		var mousepos = get_global_mouse_position()
		var size = select_start - mousepos
		draw_rect(Rect2(mousepos,size),Color.BLACK,false)

func _on_progress_bar_state_changed(new_state) -> void:
	if new_state == "Battle":
		$Player1.battle_start()

func _on_bin_mouse_entered() -> void:
	if dragging_unit:
		$Player1.remove_child(selecting_unit)
		selecting_unit.queue_free()
		dragging_unit = false

func _on_base_unit_pressed() -> void:
	if button_vals["BaseUnit"].val > 0:
		if dragging_unit:
			$Player1.remove_child(selecting_unit)
			selecting_unit.queue_free()
		dragging_unit = "BaseUnit"
		selecting_unit = preload("res://units/unit_template/unit_template.tscn").instantiate()
		set_up_placing_unit(selecting_unit)
		
func _on_tank_pressed() -> void:
	if button_vals["Tank"].val > 0:
		if dragging_unit:
			$Player1.remove_child(selecting_unit)
			selecting_unit.queue_free()	
		dragging_unit = "Tank"
		selecting_unit = preload("res://units/tank_template/tank_template.tscn").instantiate()
		set_up_placing_unit(selecting_unit)
		
func _on_sniper_pressed() -> void:
	if button_vals["Sniper"].val > 0:
		if dragging_unit:
			$Player1.remove_child(selecting_unit)
			selecting_unit.queue_free()	
		dragging_unit = "Sniper"
		selecting_unit = preload("res://units/sniper_template/sniper_template.tscn").instantiate()
		set_up_placing_unit(selecting_unit)
		

func set_up_placing_unit(selecting_unit) -> void:
	selecting_unit.get_node("CollisionShape2D").disabled = true
	selecting_unit.get_node("Vision").get_node("CollisionShape2D").disabled = true
	selecting_unit_colour = selecting_unit.modulate
	selecting_unit.modulate = Color(selecting_unit_colour.r, selecting_unit_colour.g - 0.5, selecting_unit_colour.b + 20)
	selecting_unit.z_index = 1
	print(selecting_unit)
	selecting_unit.get_node("Area2D").area_exited.connect(_on_selecting_area_exited)
	$Player1.add_child(selecting_unit)
		
func _on_selecting_area_exited(area):
	if Input.is_mouse_button_pressed(1) and selecting_unit.get_node("Area2D").get_overlapping_areas().size() < 1 and button_vals[dragging_unit].val > 0:
		button_vals[dragging_unit].val -= 1
		button_vals[dragging_unit].button.text = str(button_vals[dragging_unit].val)
		var placed_unit = null
		if dragging_unit == "BaseUnit":
			placed_unit = preload("res://units/unit_template/unit_template.tscn").instantiate()
		elif dragging_unit == "Tank":
			placed_unit = preload("res://units/tank_template/tank_template.tscn").instantiate()
		elif dragging_unit == "Sniper":
			placed_unit = preload("res://units/sniper_template/sniper_template.tscn").instantiate()
		$Player1.add_child(placed_unit)
		placed_unit.position = selecting_unit.position
		
		
