extends Node2D

var points_nodes
var points = []
var owner_colour
var zone_colour
func _ready() -> void:
	points_nodes = get_children()
	for point in points_nodes:
		points += [point.position]
		
	print(points)
	
func _process(_delta: float) -> void:
	zone_colour = get_parent().colour
	
	queue_redraw()
	
func _draw() -> void:
	if zone_colour != null:
		draw_colored_polygon(points,zone_colour)
