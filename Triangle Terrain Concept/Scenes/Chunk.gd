extends Node2D

export var coordinates : Vector2 = Vector2(0,0)
export(int, 2, 100) var points_per_edge : int = 6 #higher then 2
export(int, 0, 100) var jaggy_line_force : int = 42
export(int, 0, 100) var shard_count : int = 32
export(int, 0, 200) var zone_arround_point : int = 32

var tile = preload("res://Scenes/TriangleTile.tscn")

var chunk_size = 500
var random = RandomNumberGenerator.new()
var my_seed = ""
var polygon_points : PoolVector2Array = []
var needs_to_be_saved = false

func _ready():
	#adding itself to the list of path (and coordinates for faster access of the list)
	get_parent().chunklist_coords.append(coordinates)
	get_parent().chunklist.append(get_path())
	#generate the 4 sides
	polygon_points.append(Vector2(chunk_size, 0))
	polygon_points.append_array(set_line(Vector2(1,0)))
	polygon_points.append(Vector2(chunk_size, chunk_size))
	polygon_points.append_array(set_line(Vector2(0,1)))
	polygon_points.append(Vector2(0, chunk_size))
	polygon_points.append_array(set_line(Vector2(-1,0)))
	polygon_points.append(Vector2(0, 0))
	polygon_points.append_array(set_line(Vector2(0,-1)))
	$Polygon2D.set_polygon(polygon_points)
	start_generation()
	
func start_generation():
	generate_triangles($Polygon2D.get_polygon())

func generate_triangles(polygon : PoolVector2Array):
	#Big part of this code comes from Bramwell : https://www.youtube.com/watch?v=daT9soj7kqQ
	var points = polygon
	for _i in range(shard_count):
		var new_point = Vector2(jaggy_line_force + rand_range(0,chunk_size - jaggy_line_force*2), jaggy_line_force + rand_range(0,chunk_size - jaggy_line_force*2))
		if Geometry.is_point_in_polygon(new_point, polygon):
			var valid = true
			for point in points:
				if Geometry.is_point_in_circle(point, new_point, zone_arround_point):
					valid = false
					break
			if valid:
				points.append(new_point)
		
	var delaunay_points = Geometry.triangulate_delaunay_2d(points)
	
	if not delaunay_points:
		print("serious error occurred no delaunay points found")
	
	#loop over each returned triangle
	for index in int(len(delaunay_points) / 3.0):
		var shard_pool = PoolVector2Array()
		#find the center of our triangle
		var center = Vector2.ZERO
		
		# loop over the three points in our triangle
		for n in range(3):
			shard_pool.append(points[delaunay_points[(index * 3) + n]])
			
			center += points[delaunay_points[(index * 3) + n]]
		# adding all the points and dividing by the number of points gets the mean position
		center /= 3
		if Geometry.is_point_in_polygon(center, polygon):
			# check from simplex noise
			if PerlinNoise.is_wall(shard_pool, position):
				spawn_tile(shard_pool)
			
	#print(triangle_array)

func spawn_tile(points : PoolVector2Array):
	var Tile = tile.instance() 
	Tile.set_points(points)
	add_child(Tile)

func set_line(line_selec):
	var line_list : PoolVector2Array = []
	var offsetx = 0
	var offsety = 0

	if line_selec.x > 0:
		offsetx = chunk_size
	if line_selec.y > 0:
		offsety = chunk_size

	#line_list.append(Vector2(offsetx,offsety))
	
	random.seed = str(coordinates + line_selec/2, my_seed).hash()
	
	for i in range(points_per_edge - 2):
		var a = 0
		var b = 0
		var multa = 0
		var multb = 0
		if line_selec.x == 0:
			multb = jaggy_line_force
			a = (i+1) * (chunk_size / (points_per_edge - 1.0))
		if line_selec.y == 0:
			multa = jaggy_line_force
			b = (i+1) * (chunk_size / (points_per_edge - 1.0))
		line_list.append(Vector2(a + offsetx + random.randf_range(-multa,multa), b + offsety + random.randf_range(-multb,multb)))
	
	#if line_selec.x == 0:
	#	line_list.append(Vector2(offsetx + chunk_size, offsety))
	#if line_selec.y == 0:
	#	line_list.append(Vector2(offsetx, offsety + chunk_size))
		
	if line_selec.y == 1 || line_selec.x == -1:
		line_list.invert()
		
	return line_list
