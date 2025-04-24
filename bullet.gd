extends Area2D

@export var speed = 600
var direction = Vector2.ZERO
var shooter_id = null

func _ready():
	if is_multiplayer_authority():
		await get_tree().create_timer(5).timeout
		queue_free()

@rpc("authority")
func setup(position: Vector2, angle: float, shooter_id):
	global_position = position
	rotation = angle
	direction = Vector2.RIGHT.rotated(angle)
	self.shooter_id = shooter_id


func _physics_process(delta):
	if shooter_id == -1:
		return  # Skip logic until shooter_id is synced!

	if is_multiplayer_authority():
		global_position += direction * speed * delta

func _on_body_entered(body):
	if shooter_id == -1:
		return  # Make sure shooter_id is valid before applying damage!
	if is_multiplayer_authority():
		if body.is_in_group("tanks") and body.get_multiplayer_authority() != shooter_id:
			print_debug("[BULLET] Hit tank %s, shooter_id: %s" % [body.name, shooter_id])
			var game_manager = get_tree().root.get_node("LobbyScene")
			game_manager.rpc_id(1, "request_damage", int(body.name), 1, shooter_id)
			queue_free()
