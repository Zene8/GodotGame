extends CharacterBody2D

var MaxHealth := 100.0
var Health := 100.0:
	set(value):
		Health = clamp(value,0,MaxHealth)
var selected := false
var shifting := false
var base_speed = 25
var moving = false
var move_to := Vector2(0, 0)
var last_pos := Vector2(0, 0)
var last_pos_count = 1
var battle = false

func _process(delta: float) -> void:
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	if moving:
		if velocity.is_zero_approx():
			moving = false
		move_and_slide()
		rotation_degrees = rad_to_deg(velocity.angle())+90
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
		rotation_degrees = rad_to_deg(velocity.angle())+90

func _draw() -> void:
	draw_rect(Rect2(Vector2(-10, 10), Vector2(20, 2)),Color.RED)
	draw_rect(Rect2(Vector2(-10, 10), Vector2(Health/MaxHealth * 20, 2)),Color.GREEN)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("shift"):
		shifting = true
	if event.is_action_released("shift"):
		shifting = false
	
	if event.is_action_pressed("space") && selected:
		if shifting:
			Health += 10
		else:
			Health -= 10
	
func toggle_select():
	if selected:
		get_node("Body_unselected").visible = true
		get_node("Body_selected").visible = false
		selected = false
	else:
		get_node("Body_unselected").visible = false
		get_node("Body_selected").visible = true
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
