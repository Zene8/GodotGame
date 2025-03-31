extends Node2D

enum Owners{RED,BLUE,YELLOW,GREEN,PURPLE,ORANGE}
const OwnerColours = [Color(1,0,0,0.7),Color(0,0,1,0.7),Color(1,1,0.2,0.7),Color(0,1,0,0.7),Color(1,0,1,0.7),Color(1,0.4,0.1,0.7)]
var Money = 100
var edges
var phase
var player_colour = Owners["RED"]
var pb
var zones
var players = 6
# Called when the node enters the tree for the first time.

func _ready() -> void:
	edges = [[$Zones/nw_africa,$Zones/western_europe,0],[$Zones/western_europe,$Zones/UK,0],[$Zones/western_europe,$Zones/ne_europe,0],[$Zones/west_russia,$Zones/ne_europe,0],[$Zones/west_russia,$Zones/russia_stan,0],[$Zones/west_russia,$Zones/scandanavia,0],[$Zones/middle_east,$Zones/ne_europe,0],[$Zones/UK,$Zones/greenland,1],[$Zones/UK,$Zones/scandanavia,1],[$Zones/nw_africa,$Zones/ne_africa,0],[$Zones/ne_africa,$Zones/s_africa,0],[$Zones/sw_africa,$Zones/ne_africa,0],[$Zones/sw_africa,$Zones/nw_africa,0],[$Zones/sw_africa,$Zones/s_africa,0],[$Zones/middle_east,$Zones/ne_africa,0],[$Zones/sw_africa,$Zones/nw_africa,0],[$Zones/russia_stan,$Zones/west_russia,0],[$Zones/north_russia,$Zones/russia_stan,0],[$Zones/russia_stan,$Zones/russia_mongolia,0],[$Zones/north_russia,$Zones/russia_mongolia,0],[$Zones/north_russia,$Zones/far_east,0],[$Zones/far_east,$Zones/russia_mongolia,0],[$Zones/middle_east,$Zones/india,0],[$Zones/china,$Zones/india,0],[$Zones/china,$Zones/russia_mongolia,0],[$Zones/china,$Zones/islands,0],[$Zones/india,$Zones/islands,0],[$Zones/west_australia,$Zones/islands,1],[$Zones/east_australia,$Zones/islands,1],[$Zones/west_australia,$Zones/east_australia,0],[$Zones/ne_south_america,$Zones/nw_south_america,0],[$Zones/s_south_america,$Zones/nw_south_america,0],[$Zones/s_south_america,$Zones/ne_south_america,0],[$Zones/sw_africa,$Zones/ne_south_america,1],[$Zones/west_america,$Zones/nw_south_america,0],[$Zones/west_america,$Zones/canada,0],[$Zones/west_america,$Zones/east_america,0],[$Zones/east_america,$Zones/greenland,0],[$Zones/canada,$Zones/greenland,0],[$Zones/russia_stan,$Zones/india,0]]
	zones = $Zones
	for zone in zones.get_children():
		zone.owner_colour = Owners.values()[randi_range(0, players - 1)]
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
		if ((edge[0].selected == true or edge[1].selected == true) and not (edge[1].owner_colour == edge[0].owner_colour)) or (edge[0].selected == true and edge[1].selected == true):
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
	
