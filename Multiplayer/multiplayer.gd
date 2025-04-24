extends Node2D

@export var tank_scene: PackedScene
@export var bullet_scene: PackedScene
@onready var minigame_container = $CanvasLayer/tankGame
@onready var TankSpawner = get_node("TankSpawner")

# Spawn zone defined by an Area2D named "CollisionShape2D" under minigame_container
func get_random_spawn_position() -> Vector2:
	var shape = minigame_container.get_node("CollisionShape2D").shape

	if shape is RectangleShape2D:
		var extents = shape.extents
		var random_offset = Vector2(
			randf_range(-extents.x, extents.x),
			randf_range(-extents.y, extents.y)
		)
		return minigame_container.global_position + random_offset

	elif shape is CircleShape2D:
		var radius = shape.radius
		var angle = randf_range(0, 2 * PI)
		var distance = sqrt(randf()) * radius  # Uniform distribution
		return minigame_container.global_position + Vector2(cos(angle), sin(angle)) * distance

	push_warning("Unsupported spawn shape!")
	return minigame_container.global_position  # fallback

func _ready():
	randomize()
	NetworkManager.player_connected.connect(_on_player_connected)
	NetworkManager.player_disconnected.connect(_on_player_disconnected)

	if multiplayer.is_server():
		# Initialize own score in the shared players dictionary
		var my_id = multiplayer.get_unique_id()
		NetworkManager.players[my_id]["score"] = 0
		spawn_tank(my_id)
		send_scoreboard()

@rpc("authority", "call_local")
func spawn_tank(id):
	if tank_scene == null:
		print("❌ Error: tank_scene is not set!")
		return

	print("✅ Spawning tank for player:", id)
	var tank = tank_scene.instantiate()
	tank.name = str(id)
	tank.position = get_random_spawn_position()
	minigame_container.add_child(tank)

@rpc("any_peer", "call_local")
func request_shoot(position, rotation):
	if not multiplayer.is_server():
		return
	spawn_bullet(position, rotation, multiplayer.get_remote_sender_id())

@rpc("authority", "call_local")
func spawn_bullet(position: Vector2, rotation: float, shooter_id: int):
	if bullet_scene == null:
		print("❌ Error: bullet_scene not set!")
		return

	var bullet = bullet_scene.instantiate()
	minigame_container.add_child(bullet, true)
	bullet.setup(position, rotation, shooter_id)
	print("Bullet spawned")

@rpc("any_peer", "call_local", "reliable")
func request_damage(target_id: int, amount: int, attacker_id: int):
	if not multiplayer.is_server():
		return

	print_debug("[SERVER] Damage request from %d to target %d" % [attacker_id, target_id])
	var tank = minigame_container.get_node_or_null(str(target_id))
	if tank:
		tank.current_health = clamp(tank.current_health - amount, 0, tank.max_health)
		tank.rpc("update_healthbar", tank.current_health)

		if tank.current_health <= 0:
			handle_death(target_id, attacker_id)

func handle_death(target_id: int, attacker_id: int):
	print_debug("[SERVER] Handling death: %d killed by %d" % [target_id, attacker_id])
	var tank = minigame_container.get_node_or_null(str(target_id))
	if tank:
		register_kill(attacker_id)
		tank.queue_free()  # Remove immediately

		# Respawn after delay if still connected
		await get_tree().create_timer(5.0).timeout
		if target_id in multiplayer.get_peers() or target_id == multiplayer.get_unique_id():
			spawn_tank(target_id)

func register_kill(killer_id: int):
	if killer_id in NetworkManager.players:
		var data = NetworkManager.players[killer_id]
		data["score"] = data.get("score", 0) + 1
		send_scoreboard()
	else:
		print_debug("⚠️ Unknown killer_id %d" % killer_id)

func _on_player_connected(peer_id, player_info):
	print("✅ Player connected:", peer_id)
	if multiplayer.is_server():
		# Initialize new player's score
		NetworkManager.players[peer_id]["score"] = 0
		spawn_tank(peer_id)
		send_scoreboard()

func _on_player_disconnected(peer_id):
	print("👋 Player disconnected:", peer_id)
	if multiplayer.is_server():
		NetworkManager.players.erase(peer_id)
		send_scoreboard()

	var tank = minigame_container.get_node_or_null(str(peer_id))
	if tank:
		tank.queue_free()

@rpc("authority")
func send_scoreboard():
	# Send only scores mapping to clients
	var scores = {}
	for id in NetworkManager.players.keys():
		scores[id] = NetworkManager.players[id].get("score", 0)
	rpc("update_scoreboard", scores)

@rpc("any_peer")
func update_scoreboard(server_scores: Dictionary):
	print("Current Scores:", server_scores)




@rpc
func set_player_color(color_enum: int):
	print("My color enum is:", color_enum)

@rpc
func update_player_list(player_data: Dictionary):
	print("Player list received:", player_data)
