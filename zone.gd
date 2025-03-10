extends Node2D
signal Buy(amount)
var troops = {"Basic":0,"Advanced":0,"Ranged":0}
var Money
var basic
var costs = {"Basic":10,"Advanced":15,"Ranged":12}
var MoneyLabel
var TroopCountLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	basic = $"CanvasLayer/Main panel/MainV/Troops/Basic/Bnumber"
	MoneyLabel = $"CanvasLayer/Main panel/MainV/Shop/HBoxContainer/MoneyLabel"
	$"CanvasLayer/Main panel".visible=false
	TroopCountLabel = $TroopCount
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	Money = get_parent().get_parent().Money
	basic.text = str(troops["Basic"])
	MoneyLabel.text = str(Money)
	TroopCountLabel.text = str(TroopCount())
	
func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("L_click"):
		$"CanvasLayer/Main panel".visible=true



func _on_b_button_pressed() -> void:
	if Money >= costs["Basic"]:
		troops["Basic"] +=1
		Buy.emit(-costs["Basic"])


func _on_exit_pressed() -> void:
	$"CanvasLayer/Main panel".visible=false
	
func TroopCount():
	var count = 0
	for troop in troops:
		count += troops[troop]
	return count
