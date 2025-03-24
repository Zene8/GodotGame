extends CharacterBody2D

const max_health := 100.0
var health := 100.0:
	set(value):
		health = clamp(value,0,max_health)
var selected := false
var shifting := false
var base_speed = 50
var moving = false
var move_to := Vector2(0, 0)
var last_pos := Vector2(0, 0)
var last_pos_count = 1
var battle := false
var player = 1

func _process(delta: float) -> void:
	queue_redraw()
	
func _ready() -> void:
	if get_parent().name == "Player1":
		player = 1
		$Area2D.set_collision_layer_value(1, true)
		$Area2D.set_collision_layer_value(2, false)
	else:
		player = 2
		$Area2D.set_collision_layer_value(2, true)
		$Area2D.set_collision_layer_value(1, false)
	
func _physics_process(delta: float) -> void:
	if moving:
		if velocity.is_zero_approx():
			moving = false
		move_and_slide()
		velocity = (move_to - position).normalized() * base_speed
		if last_pos_count >= 2:
			if (last_pos - position).length() < 0.01:
				moving = false
			else:
				last_pos_count = 0
				last_pos = position
		last_pos_count += 1
	elif battle:
		move_and_slide()
		velocity = move_to
		
	
func _draw() -> void:
	if selected:
		draw_circle(Vector2(0,0),10,Color.WHITE,true)
	draw_circle(Vector2(0,0),8,Color.RED,false,3)
	draw_arc(Vector2(0,0),8,PI*(1.0/2-health/max_health),PI*(1.0/2+health/max_health),30,Color.GREEN,3)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
	
	if event.is_action_pressed("space") && selected:
		if shifting:
			health += 10
		else:
			health -= 10
	
func toggle_select():
	if selected:
		selected = false
	else:
		selected = true

func set_current_velocity(mousepos):
	velocity = (mousepos - position).normalized() * base_speed
	move_to = mousepos
	
func unit_battle_start(direction):
	velocity = direction.normalized() * base_speed
	move_to = direction.normalized() * base_speed
	battle = true
	
func set_moving(val):
	moving = val

func damage(damage):
	health -= damage
	if health == 0:
		queue_free()
	
	
