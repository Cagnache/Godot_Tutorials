extends Node2D

var speed = 1500

export var Chunks_path : NodePath
onready var Chunks = get_node(Chunks_path)
var last_chunk = Vector2(0,0)


#All this code might be better in a singleton for chunk management 
func _ready():
	last_chunk = Chunks.get_closest_chunk(global_position)
	var coord = Chunks.get_closest_chunk(global_position)
	Chunks.create_chunks_arround_coordinates(coord, 2)

func _input(event):
	#To force generation
	if event.is_action_pressed("ui_accept"):
		var coord = Chunks.get_closest_chunk(global_position)
		Chunks.create_chunks_arround_coordinates(coord, 9)
		

func _process(delta):
	var horizontal = int(Input.is_action_pressed("ui_right")) - int(Input.is_action_pressed("ui_left"))
	var vertical = int(Input.is_action_pressed("ui_down")) - int(Input.is_action_pressed("ui_up"))
	
	position += Vector2(horizontal * speed * delta ,vertical * speed * delta)
	
	#Check for the chunk
	var new_chunk = Chunks.get_closest_chunk(global_position)
	if new_chunk != last_chunk:
		last_chunk = new_chunk
		Chunks.clear_chunks_arround_coordinates(last_chunk, 9)
		Chunks.create_chunks_arround_coordinates(last_chunk, 5)
		
