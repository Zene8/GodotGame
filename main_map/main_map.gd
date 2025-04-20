extends Node2D

signal SceneChange(scene)
enum Owners{RED,BLUE,YELLOW,GREEN,PURPLE,ORANGE}
const OwnerColours = [Color(1,0,0,0.7),Color(0,0,1,0.7),Color(1,1,0.2,0.7),Color(0,1,0,0.7),Color(1,0,1,0.7),Color(1,0.4,0.1,0.7)]
var colour:
	get:
		return OwnerColours[player_colour]
var player_money = [0,0,0,0,0,0]
var Start_Money = 100
var edges
var phase = "Buy Phase"
var player_colour = Owners["RED"]
var pb
var zones
var players = 2
var attackpanel
var targeted_zone
# Called when the node enters the tree for the first time.

func _ready() -> void:
	for i in range(len(player_money)):
		player_money[i] = Start_Money
	edges = [[$Zones/nw_africa,$Zones/western_europe,0],[$Zones/western_europe,$Zones/UK,0],[$Zones/western_europe,$Zones/ne_europe,0],[$Zones/west_russia,$Zones/ne_europe,0],[$Zones/west_russia,$Zones/russia_stan,0],[$Zones/west_russia,$Zones/scandanavia,0],[$Zones/middle_east,$Zones/ne_europe,0],[$Zones/UK,$Zones/greenland,1],[$Zones/UK,$Zones/scandanavia,1],[$Zones/nw_africa,$Zones/ne_africa,0],[$Zones/ne_africa,$Zones/s_africa,0],[$Zones/sw_africa,$Zones/ne_africa,0],[$Zones/sw_africa,$Zones/nw_africa,0],[$Zones/sw_africa,$Zones/s_africa,0],[$Zones/middle_east,$Zones/ne_africa,0],[$Zones/sw_africa,$Zones/nw_africa,0],[$Zones/russia_stan,$Zones/west_russia,0],[$Zones/north_russia,$Zones/russia_stan,0],[$Zones/russia_stan,$Zones/russia_mongolia,0],[$Zones/north_russia,$Zones/russia_mongolia,0],[$Zones/north_russia,$Zones/far_east,0],[$Zones/far_east,$Zones/russia_mongolia,0],[$Zones/middle_east,$Zones/india,0],[$Zones/china,$Zones/india,0],[$Zones/china,$Zones/russia_mongolia,0],[$Zones/china,$Zones/islands,0],[$Zones/india,$Zones/islands,0],[$Zones/west_australia,$Zones/islands,1],[$Zones/east_australia,$Zones/islands,1],[$Zones/west_australia,$Zones/east_australia,0],[$Zones/ne_south_america,$Zones/nw_south_america,0],[$Zones/s_south_america,$Zones/nw_south_america,0],[$Zones/s_south_america,$Zones/ne_south_america,0],[$Zones/sw_africa,$Zones/ne_south_america,1],[$Zones/west_america,$Zones/nw_south_america,0],[$Zones/west_america,$Zones/canada,0],[$Zones/west_america,$Zones/east_america,0],[$Zones/east_america,$Zones/greenland,0],[$Zones/canada,$Zones/greenland,0],[$Zones/russia_stan,$Zones/india,0]]
	zones = $Zones
	attackpanel = $CanvasLayer/attack_panel
	attackpanel.visible = false
	for zone in zones.get_children():
		zone.owner_colour = Owners.values()[randi_range(0, players - 1)]
		zone.Buy.connect(change_money)
		zone.attacked.connect(attacking)
	pb = $CanvasLayer/PanelContainer/ProgressBar
	pb.get("theme_override_styles/fill").bg_color = colour


func _process(delta: float) -> void:
	var win = true
	for zone in zones.get_children():
		zone.targeted = false
		if zone.owner_colour != player_colour:
			win = false
			
	for edge in edges:
		if edge[0].selected == true:
			if edge[1].owner_colour != edge[0].owner_colour:
				edge[1].targeted = true
		if edge[1].selected == true:
			if edge[1].owner_colour != edge[0].owner_colour:
				edge[0].targeted = true
				
	queue_redraw()
	if win:
		end_game()
	
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
	if event.is_action_pressed("R_click") and phase == "Attack Phase":
		for zone in zones.get_children():
			zone.selected = false
			
func change_money(amount):
	player_money[player_colour] += amount
	
func attacking(attacked_zone):
	targeted_zone = attacked_zone
	var select_zones = $CanvasLayer/attack_panel/VBoxContainer/select_zones
	for zone in select_zones.get_children():
		zone.queue_free()
	for zone in zones.get_children():
		if zone.selected and (([attacked_zone,zone,0] in edges) or ([attacked_zone,zone,1] in edges) or ([zone,attacked_zone,0] in edges) or ([zone,attacked_zone,1] in edges)):
			var troop_select_panel = preload("res://main_map/troop_select_panel.tscn").instantiate()
			troop_select_panel.get_node("PanelContainer/MainH/soliderH/VSlider").max_value = float(zone.troops["Basic"])
			troop_select_panel.get_node("PanelContainer/MainH/advancedH/VSlider").max_value = float(zone.troops["Advanced"])
			troop_select_panel.get_node("PanelContainer/MainH/sniperH/VSlider").max_value = float(zone.troops["Ranged"])
			troop_select_panel.get_node("PanelContainer/MainH/medicH/VSlider").max_value = float(zone.troops["Medic"])
			troop_select_panel.get_node("PanelContainer/MainH/tankH/VSlider").max_value = float(zone.troops["Tank"])
			troop_select_panel.get_node("PanelContainer/MainH/eliteH/VSlider").max_value = float(zone.troops["Elite"])
			troop_select_panel.get_node("PanelContainer/MainH/zone_name").text = zone.name
			select_zones.add_child(troop_select_panel)
	attackpanel.visible = true
	
	
func _on_progress_bar_state_changed(new_phase) -> void:
	for zone in zones.get_children():
		zone.selected = false
		
	if new_phase == "Attack Phase":
		for zone in get_node("Zones").get_children():
			zone.get_node("CanvasLayer").get_node("Main_panel").visible = false
	elif new_phase == "Buy Phase":
		_on_cancel_pressed()
		player_colour = player_colour + 1
		if player_colour == players:
			player_colour = 0
			add_money()
	phase = new_phase
	pb.get("theme_override_styles/fill").bg_color = colour


func _on_confirm_pressed() -> void:
	var valid = true
	var troop_amounts = [0,0,0,0,0,0]
	var troop_names = ["soliderH","advancedH","sniperH","medicH","tankH","eliteH"]
	var real_troop_names = ["Basic","Advanced","Ranged","Medic","Tank","Elite"]
	var select_zones = $CanvasLayer/attack_panel/VBoxContainer/select_zones
	for zone in select_zones.get_children():
		var remaining_troops = false
		for i in range(6):
			var slider = zone.get_node("PanelContainer/MainH/"+troop_names[i]+"/VSlider")
			if slider.max_value != slider.value:
				remaining_troops = true
		if !remaining_troops:
			valid = false
			break
			
	if valid:
		for zone in select_zones.get_children():
			var real_zone = zones.get_node(zone.get_node("PanelContainer/MainH/zone_name").text) 
			for i in range(6):
				var slider = zone.get_node("PanelContainer/MainH/"+troop_names[i]+"/VSlider")
				real_zone.troops[real_troop_names[i]] -= int(slider.value)
				troop_amounts[i] += int(slider.value)
		var battle_scene = preload("res://map/map.tscn").instantiate()
		battle_scene.button_vals["unit"].val = troop_amounts[0]
		battle_scene.button_vals["tank"].val = troop_amounts[4]
		battle_scene.button_vals["sniper"].val = troop_amounts[2]
		battle_scene.button_vals["heavy"].val = troop_amounts[1]
		battle_scene.button_vals["medic"].val = troop_amounts[3]
		battle_scene.button_vals["elite"].val = troop_amounts[5]
		battle_scene.set_player_colours(player_colour, targeted_zone.owner_colour)
		SceneChange.emit(battle_scene)
		for zone in select_zones.get_children():
			zone.queue_free()
		get_node("Camera2D").enabled = false
		attackpanel.visible = false


func _on_cancel_pressed() -> void:
	var select_zones = $CanvasLayer/attack_panel/VBoxContainer/select_zones
	for zone in select_zones.get_children():
		zone.queue_free()
	attackpanel.visible = false
	
func handle_battle(Win,amount):
	if Win == false:
		targeted_zone.troops["Basic"] = amount[0]
		targeted_zone.troops["Advanced"] = amount[1]
		targeted_zone.troops["Sniper"] = amount[2]
		targeted_zone.troops["Medic"] = amount[3]
		targeted_zone.troops["Tank"] = amount[4]
		targeted_zone.troops["Elite"] = amount[5]
		
	if Win == true:
		targeted_zone.owner_colour = player_colour
		targeted_zone.troops["Basic"] = amount[0]
		targeted_zone.troops["Advanced"] = amount[1]
		targeted_zone.troops["Sniper"] = amount[2]
		targeted_zone.troops["Medic"] = amount[3]
		targeted_zone.troops["Tank"] = amount[4]
		targeted_zone.troops["Elite"] = amount[5]

func end_game():
	pass

func territories_owned(player):
	var count = 0
	for zone in zones.get_children():
		if zone.owner_colour == player:
			count += 1
	return count

func add_money():
	for i in range(players):
		player_money[i] += 10*territories_owned(i)
