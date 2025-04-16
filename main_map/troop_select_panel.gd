extends Control
var troop_names = ["solider","advanced","sniper","medic","tank"]

func _process(delta: float) -> void:
	for i in range(5):
		var slider = get_node("PanelContainer/MainH/"+troop_names[i]+"H/VSlider")
		var label = get_node("PanelContainer/MainH/"+troop_names[i]+"H/"+troop_names[i]+"/soldier_amount")
		var newtext = str(int(slider.value))+"/"+str(int(slider.max_value))
		label.text = newtext
