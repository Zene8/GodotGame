extends Camera2D

var dragging := false
var dragstart := Vector2()
var startpos := Vector2()
var maxzoom := 1.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if dragging:
		position = startpos + (dragstart - get_global_mouse_position())
	if zoom < Vector2(maxzoom,maxzoom):
		zoom = Vector2(maxzoom,maxzoom)
	if abs(position.x) > 250:
		position.x = position.x * abs(250/position.x)
	if abs(position.y) > 150:
		position.y = position.y * abs(150/position.y)
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("Scroll_up"):
		zoom += Vector2(0.1,0.1)
	if event.is_action_pressed("Scroll_down"):
		zoom -= Vector2(0.1,0.1)
		
	if event.is_action_pressed("L_click"):
		if not Input.is_key_pressed(KEY_SHIFT):
			dragging = true
			dragstart = get_global_mouse_position()
			startpos = position
	if event.is_action_released("L_click"):
		dragging = false
