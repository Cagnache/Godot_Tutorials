tool

extends Node2D

export var points : PoolVector2Array setget set_points

func set_points(new_points : PoolVector2Array):
	points = new_points
	if len(new_points) > 2:
		$Polygon2D.set_polygon(new_points)

func _ready():
	var center = (points[0] + points[1] + points[2]) / 3 + global_position
	var value = 1 - PerlinNoise.combined_noise_value(center) * 1.5
	$Polygon2D.color = Color(value, value, value)

