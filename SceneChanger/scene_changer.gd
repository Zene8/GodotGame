extends Node

var Main_map
var zones
var state = "Map"
var map_progress_bar
func _ready() -> void:
	map_progress_bar = get_node("Main_map/CanvasLayer/PanelContainer/ProgressBar")
	Main_map = get_node("Main_map")
	zones = get_node("Main_map/Zones")
	Main_map.SceneChange.connect(ChangeSceneToBattle)
	
		
func ChangeSceneToBattle(scene):
	state = "Battle"
	map_progress_bar.game_state = state
	for scenes in get_children():
		scenes.visible = false
		scenes.get_child(-1).visible = false
	add_child(scene)
	scene.BattleFinished.connect(ChangeSceneToMap)
	

func ChangeSceneToMap(Win,amount):
	state = "Map"
	map_progress_bar.game_state = state
	Main_map.handle_battle(Win,amount)
	Main_map.get_node("Camera2D").enabled = true
	Main_map.visible = true
	Main_map.get_child(-1).visible = true
