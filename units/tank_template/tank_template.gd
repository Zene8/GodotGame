extends CharacterBody2D

const max_health := 500.0
var health := 500:
	set(value):
		health = clamp(value,0,max_health)
var selected := false
var shifting := false
var moving = false
var move_to := Vector2(0, 0)
var last_pos := Vector2(0, 0)
var last_pos_count = 1
var battle = false
var player = null
var bloom = 0.2
var shooting = false
var bullet_distance = 1
var rng = RandomNumberGenerator.new()
var target_unit = null
var unit_hit = false
var target = null
var battle_mode = "Charge"
const base_speed = 25
const bullet_speed = 10

func _ready() -> void:
	var vision_detection = $Vision
	if get_parent().name == "Player1":
		player = 1
		vision_detection.set_collision_mask_value(2, true)
		vision_detection.set_collision_mask_value(1, false)
		$Area2D.set_collision_layer_value(2, false)
		$Area2D.set_collision_layer_value(1, true)
	else:
		player = 2
		vision_detection.set_collision_mask_value(1, true)
		vision_detection.set_collision_mask_value(2, false)
		$Area2D.set_collision_layer_value(2, true)
		$Area2D.set_collision_layer_value(1, false)
		
func _process(delta: float) -> void:
	if target_unit:
		$Turret.rotation_degrees = rad_to_deg((target_unit.position - position).angle()) - rotation_degrees + 90
	queue_redraw()
	
func _physics_process(delta: float) -> void:
	if moving:
		if shooting:
			velocity = Vector2(0, 0)
		else:
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
	elif battle and battle_mode == "Charge":
		move_and_slide()
		velocity = Vector2(-1, 0) * base_speed
		rotation_degrees = rad_to_deg(velocity.angle())+90

func _draw() -> void:
	draw_rect(Rect2(Vector2(-10, 10), Vector2(20, 2)),Color.RED)
	draw_rect(Rect2(Vector2(-10, 10), Vector2(health/max_health * 20, 2)),Color.GREEN)
	if shooting:
		draw_line(shooting*(bullet_distance-10), shooting*(bullet_distance-0.9), Color.YELLOW)
		bullet_distance += bullet_speed
	if target_unit != null and shooting and unit_hit:
		if Vector2(shooting*(bullet_distance-0.9)).length() >= Vector2(target).length():
			shooting = false
			unit_hit = false
			if target_unit.get("health") <= 100:
				target_unit.damage(100)
				target_unit = null
			else:
				target_unit.damage(100)
			
	
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
	battle = true

func set_moving(val):
	moving = val

func _on_vision_area_entered(area: Area2D) -> void:
	if $Reload.time_left == 0.0:
		if target_unit == null:
			target_unit = area.get_parent()
		shooting = (area.get_parent().position - position).rotated(-rotation+rng.randf_range(-bloom, bloom))
		var bullet_path = RayCast2D.new()
		bullet_path.position = Vector2(0, 0)
		bullet_path.target_position = shooting
		target = shooting
		add_child(bullet_path)
		bullet_path.force_raycast_update()
		if bullet_path.is_colliding():
			unit_hit = true
		shooting = shooting.normalized()
		$Reload.start()
		bullet_distance = 1
	

func _on_reload_timeout() -> void:
	if $Vision.has_overlapping_areas():
		if target_unit == null:
			target_unit = $Vision.get_overlapping_areas()[0].get_parent()
		var area = $Vision.get_overlapping_areas()[0]
		shooting = (area.get_parent().position - position).rotated(-rotation+rng.randf_range(-bloom, bloom))
		var bullet_path = RayCast2D.new()  
		bullet_path.position = Vector2(0, 0)
		bullet_path.target_position = shooting
		target = shooting
		add_child(bullet_path)
		bullet_path.force_raycast_update()
		if bullet_path.is_colliding():
			unit_hit = true
		shooting = shooting.normalized()
		$Reload.start()
	else:
		shooting = false
	bullet_distance = 1
	
func _on_vision_area_exited(area: Area2D) -> void:
	if target_unit == area.get_parent():
		target_unit = null
		if $Vision.has_overlapping_areas():
			target_unit = $Vision.get_overlapping_areas()[0].get_parent()
		
	
func damage(damage):
	health -= damage
	if health <= 0:
		queue_free()

func set_battle_mode(new_mode):
	battle_mode = new_mode
