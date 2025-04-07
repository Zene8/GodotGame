extends Node

var Main_map
var zones
func _ready() -> void:
	Main_map = get_node("Main_map")
	zones = get_node("Main_map/Zones")
	for zone in zones.get_children():
		zone.SceneChange.connect(ChangeSceneToBattle)
	
		
func ChangeSceneToBattle(scene):
	for scenes in get_children():
		scenes.visible = false
		scenes.get_child(-1).visible = false
	add_child(scene)
	scene.BattleFinished.connect(ChangeSceneToMap)
	

func ChangeSceneToMap(Win,amount):
	if Win == false:
		#SET attacked zone to amount
		pass
		
	if Win == true:
		#Set losing zone to colour of winner and move troops accross
		pass
		
	Main_map.get_node("Camera2D").enabled = true
	Main_map.visible = true
	Main_map.get_child(-1).visible = true
