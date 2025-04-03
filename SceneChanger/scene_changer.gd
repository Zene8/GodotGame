extends Node

var zones
func _ready() -> void:
	zones = get_node("Main_map/Zones")
	for zone in zones.get_children():
		zone.SceneChange.connect(ChangeScene)
		
func ChangeScene(scene):
	for scenes in get_children():
		scenes.visible = false
		scenes.get_child(-1).visible = false
	add_child(scene)
	
