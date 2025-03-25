extends Node2D

enum Owners{RED,BLUE,YELLOW,GREEN,PURPLE,ORANGE}
const OwnerColours = [Color(1,0,0,0.4),Color(0,0,1,0.4),Color(1,1,0.2,0.4),Color(0,1,0,0.4),Color(1,0,1,0.4),Color(1,0.4,0.1,0.4)]
var Money = 100
var edges
var phase
var player_colour = Owners["RED"]
var pb
var zones
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	edges = [[$Zones/nw_africa,$Zones/western_europe,0],[$Zones/western_europe,$Zones/UK,0],[$Zones/UK,$Zones/greenland,1]]
	zones = $Zones
	for zone in zones.get_children():
		zone.owner_colour = Owners.values()[randi_range(0, Owners.size() - 1)]
		zone.Buy.connect(change_money)
	pb = $CanvasLayer/PanelContainer/ProgressBar
	pb.get("theme_override_styles/fill").bg_color = Color(1,0,0,0.4)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for zone in zones.get_children():
		zone.targeted = false
	for edge in edges:
		if edge[0].selected == true:
			if edge[1].owner_colour != edge[0].owner_colour:
				edge[1].targeted = true
		if edge[1].selected == true:
			if edge[1].owner_colour != edge[0].owner_colour:
				edge[0].targeted = true
				
	queue_redraw()
	
	
func _draw() -> void:
	for edge in edges:
		if edge[0].selected == true or edge[1].selected == true:
			draw_line(edge[0].position,edge[1].position,Color.WHITE,3)
		elif edge[2] == 0:
			draw_line(edge[0].position,edge[1].position,Color.BLACK,3)
		elif edge[2] == 1:
			draw_line(edge[0].position,edge[1].position,Color.BLUE,3)
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("L_click"):
		var mousepos = get_global_mouse_position()
		#for zone in zones.get_children():
			#if zone.Area2D.c
			
func change_money(amount):
	Money += amount
	
func _on_progress_bar_state_changed(new_phase) -> void:
	if phase == "Buy Phase":
		for zone in get_node("Zones").get_children():
			zone.get_node("CanvasLayer").get_node("Main_panel").visible = false	
	phase = new_phase
	
