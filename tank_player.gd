extends CharacterBody2D

@export var speed = 200.0
@export var bullet_scene: PackedScene
@onready var turret = $Turrent
@onready var turretHead = $Turrent/TurrentHead
@onready var Body = $Body
@onready var HealthBar = $HealthBarCont/ColorRect
@onready var sync = $Sync  # Critical synchronization node

var last_hit_by = null
var max_health = 10

# Synchronized health property

@export var current_health = max_health

func _enter_tree():
	set_multiplayer_authority(str(name).to_int())
	print(get_multiplayer_authority())
	var peer_id = multiplayer.get_unique_id()
	print_debug("[PEER %d][TANK %s] Authority set to: %d" % [peer_id, name, get_multiplayer_authority()])

func _ready():
	add_to_group("tanks")
	var peer_id = multiplayer.get_unique_id()
	if not sync:
		push_error("[PEER %d] MultiplayerSynchronizer node missing!" % peer_id)
		return
	sync.set_multiplayer_authority(str(name).to_int())
	print_debug("[PEER %d][TANK %s] Initializing tank, health: %d/%d" % [peer_id, name, current_health, max_health])
	update_healthbar(current_health)
	if HealthBar:
		HealthBar.scale.x = float(current_health) / max_health
	else:
		push_error("[PEER %d] HealthBar reference is missing!" % peer_id)


@rpc("any_peer", "call_local", "reliable")
func flash():
	var peer_id = multiplayer.get_unique_id()
	print_debug("[PEER %d][TANK %s] flash() invoked" % [peer_id, name])
	Body.modulate = Color.RED
	await get_tree().create_timer(0.2).timeout
	Body.modulate = Color.WHITE

@rpc("call_local")
func set_tank_visible(state: bool):
	visible = state



@rpc("any_peer", "call_local", "reliable")
func update_healthbar(health):
	current_health = health
	var ratio = float(current_health) / max_health
	if HealthBar:
		HealthBar.scale.x = ratio
		HealthBar.modulate = Color(1 - ratio, ratio, 0)
	var peer_id = multiplayer.get_unique_id()
	print_debug("[PEER %d][TANK %s] Healthbar updated to %.1f%%" % [peer_id, name, ratio * 100])


#good code, don't modify
func _input(event):
	if is_multiplayer_authority() and event.is_action_pressed("shoot"):
		shoot()

func aim_turret():
	if is_multiplayer_authority():
		var mouse_position = get_global_mouse_position()
		var turret_global_pos = turretHead.global_position
		var target_angle = (mouse_position - turret_global_pos).angle() + PI / 2
		turret.rotation = lerp_angle(turret.rotation, target_angle, 0.1)

func shoot():
	if is_multiplayer_authority():
		var mouse_position = get_global_mouse_position()
		var turret_global_pos = turretHead.global_position
		var angle_to_mouse = (mouse_position - turret_global_pos).angle()
		#print_debug("[CLIENT][TANK %s] shoot() at angle: %.2f" % [name, angle_to_mouse])
		var game_manager = get_tree().root.get_node("LobbyScene")
		game_manager.rpc("request_shoot", turret_global_pos, angle_to_mouse)
		
func _process(delta):
	if is_multiplayer_authority():
		handle_movement(delta)
		aim_turret()

func handle_movement(delta):

	var input_vector = Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)
	velocity = input_vector.normalized() * speed if input_vector.length() > 0 else Vector2.ZERO
	move_and_slide()
