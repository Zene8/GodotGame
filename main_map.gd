extends Node2D

var edges

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	edges = [[$Zones/Zone,$Zones/Zone2,0],[$Zones/Zone2,$Zones/Zone3,0],[$Zones/Zone3,$Zones/Zone4,1]]
	var zones = $Zones

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	queue_redraw()
	
	
func _draw() -> void:
	for edge in edges:
		if edge[2] == 0:
			draw_line(edge[0].position,edge[1].position,Color.BLACK,3)
		elif edge[2] == 1:
			draw_line(edge[0].position,edge[1].position,Color.BLUE,3)
			
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("L_click"):
		var mousepos = get_global_mouse_position()
		#for zone in zones.get_children():
			#if zone.Area2D.c
