extends Node2D
map scene packed scene

@rpc("authority", "call_local")
func spawn_map(id):
	if tank_scene == null:
		print("❌ Error: tank_scene is not set!")
		return

	print("✅ Spawning tank for player:", id)
	var tank = scene.instantiate()
	scene.name = str(id)
	game.add_child(scene)
