extends CharacterBody2D

var MaxHealth := 100.0
var Health := 100.0:
	set(value):
		Health = clamp(value,0,MaxHealth)
var selected := true
var shifting := false
var base_speed = 50
var moving = false
var move_to := Vector2(0, 0)
var last_pos := Vector2(0, 0)
var last_pos_count = 1

func _process(delta: float) -> void:
	queue_redraw()
	
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
	
func _draw() -> void:
	if selected:
		draw_circle(Vector2(0,0),10,Color.WHITE,true)
	draw_circle(Vector2(0,0),8,Color.RED,false,3)
	draw_arc(Vector2(0,0),8,PI*(1.0/2-Health/MaxHealth),PI*(1.0/2+Health/MaxHealth),30,Color.GREEN,3)
	
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
		selected = false
	else:
		selected = true

func set_current_velocity(mousepos):
	velocity = (mousepos - position).normalized() * base_speed
	move_to = mousepos

func set_moving(val):
	moving = val
	
	
