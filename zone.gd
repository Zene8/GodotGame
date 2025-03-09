extends Node2D
var troops = {"Basic":0,"Advanced":0,"Ranged":0}
var Money := 100
var basic
var costs = {"Basic":10,"Advanced":15,"Ranged":12}
var MoneyLabel
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	basic = $"CanvasLayer/Main panel/MainV/Troops/Basic/Bnumber"
	MoneyLabel = $"CanvasLayer/Main panel/MainV/Shop/HBoxContainer/MoneyLabel"
	$"CanvasLayer/Main panel".visible=false
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	basic.text = str(troops["Basic"])
	MoneyLabel.text = str(Money)

func _on_area_2d_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event.is_action_pressed("L_click"):
		$"CanvasLayer/Main panel".visible=true



func _on_b_button_pressed() -> void:
	if Money >= costs["Basic"]:
		troops["Basic"] +=1
		Money -= costs["Basic"]


func _on_exit_pressed() -> void:
	$"CanvasLayer/Main panel".visible=false
