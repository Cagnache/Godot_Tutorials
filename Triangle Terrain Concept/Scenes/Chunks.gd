extends Node2D

var chunk = preload("res://Scenes/Chunk.tscn")
const chunk_size = 500

var chunklist_coords = []
var chunklist = []

var my_seed = "2"

func _ready():
	#spawn_chunks()
	pass

func spawn_chunks():
	for i in range(10):
		for y in range(10):
			var Chunk = chunk.instance() 
			Chunk.coordinates = Vector2(i, y)
			Chunk.position = Vector2(i*chunk_size,y*chunk_size)
			Chunk.chunk_size = chunk_size
			Chunk.my_seed = my_seed
			add_child(Chunk)

func spawn_chunk_coordinates(coordinates : Vector2):
	if is_chunk_generated(coordinates):
		return
	var Chunk = chunk.instance() 
	Chunk.coordinates = coordinates
	Chunk.position = coordinates*chunk_size
	Chunk.chunk_size = chunk_size
	Chunk.my_seed = my_seed
	add_child(Chunk)

func unload_chunks_except(active_chunks : Array):
	for child in get_children():
		if not active_chunks.has(child.coordinates): 
			if child.needs_to_be_saved == false:
				delete_chunk_coords(child.coordinates)
				child.queue_free()
			

func create_chunks_arround_coordinates(_coords : Vector2,  spawn_range : float = 2):
	var active_chunks = []
	for i in range(spawn_range * 2 - 1):
		for y in range(spawn_range * 2 - 1):
			var offset = Vector2(i - spawn_range + 1, y - spawn_range + 1)
			active_chunks.append(offset + _coords)
	for _chunk in active_chunks:
		spawn_chunk_coordinates(_chunk)
		
func clear_chunks_arround_coordinates(_coords : Vector2,  spawn_range : float = 2):
	var active_chunks = []
	for i in range(spawn_range * 2 - 1):
		for y in range(spawn_range * 2 - 1):
			var offset = Vector2(i - spawn_range + 1, y - spawn_range + 1)
			active_chunks.append(offset + _coords)
	unload_chunks_except(active_chunks)
	
	

func get_closest_chunk(coordinates : Vector2):
	return Vector2(floor(coordinates.x/chunk_size),floor(coordinates.y/chunk_size))

func is_chunk_generated(_coords : Vector2):
	return chunklist_coords.has(_coords)

func get_chunk(_coords : Vector2):
	return get_node(chunklist[chunklist_coords.find(_coords)])
	
func delete_chunk_coords(_coords : Vector2):
	var index = chunklist_coords.find(_coords)
	chunklist.pop_at(index)
	chunklist_coords.pop_at(index)
