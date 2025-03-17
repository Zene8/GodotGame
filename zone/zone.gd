extends Node2D
signal Buy(amount)
enum Owners{RED,BLUE,YELLOW,GREEN,PURPLE,ORANGE}
const OwnerColours = [Color(1,0,0,0.4),Color(0,0,1,0.4),Color(1,1,0.2,0.4),Color(0,1,0,0.4),Color(1,0,1,0.4),Color(1,0.4,0.1,0.4)]
var troops = {"Basic":0,"Advanced":0,"Ranged":0}
var Money
var basic
var advanced
var ranged
var costs = {"Basic":10,"Advanced":15,"Ranged":12}
var MoneyLabel
var TroopCountLabel
var owner_colour = Owners["RED"]
var colour:
	get:
		return OwnerColours[owner_colour]
var phase
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	basic = $"CanvasLayer/Main_panel/MainV/Troops/Basic/Bnumber"
	advanced = $CanvasLayer/Main_panel/MainV/Troops/Advanced/Anumber
	ranged = $CanvasLayer/Main_panel/MainV/Troops/Ranged/Rnumber
	MoneyLabel = $"CanvasLayer/Main_panel/MainV/Shop/HBoxContainer/MoneyLabel"
	$"CanvasLayer/Main_panel".visible=false
	TroopCountLabel = $TroopCount
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	var parent = get_parent().get_parent()
	if parent != null:
		Money = parent.Money
		phase = parent.phase
		basic.text = str(troops["Basic"])
		advanced.text = str(troops["Advanced"])
		ranged.text = str(troops["Ranged"])
		MoneyLabel.text = str(Money)
	TroopCountLabel.text = str(TroopCount())
	
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("L_click") and get_node("/root/Main_map").player_colour == owner_colour and phase == "Buy Phase":
		for zone in get_parent().get_children():
			zone.get_node("CanvasLayer").get_node("Main_panel").visible = false	
		$"CanvasLayer/Main_panel".visible=true

func _on_b_button_pressed() -> void:
	if Money >= costs["Basic"]:
		troops["Basic"] +=1
		Buy.emit(-costs["Basic"])

func _on_a_button_pressed() -> void:
	if Money >= costs["Advanced"]:
		troops["Advanced"] +=1
		Buy.emit(-costs["Advanced"])

func _on_r_button_pressed() -> void:
	if Money >= costs["Ranged"]:
		troops["Ranged"] +=1
		Buy.emit(-costs["Ranged"])
	
	
func _on_exit_pressed() -> void:
	$"CanvasLayer/Main_panel".visible=false
	

func TroopCount():
	var count = 0
	for troop in troops:
		count += troops[troop]
	return count
