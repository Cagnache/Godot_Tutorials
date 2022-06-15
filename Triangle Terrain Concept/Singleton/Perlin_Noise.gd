extends Node

var noise = OpenSimplexNoise.new()
var density = OpenSimplexNoise.new()

func _ready():
	setup_noise()
	set_seed()

func set_seed(new_seed : int = 0):
	if new_seed == 0:
		noise.seed = randi()
		density.seed = randi()
	else:
		noise = new_seed
		density = new_seed

func setup_noise():
	# Configure
	noise.octaves = 3
	noise.period = 2000
	noise.persistence = 0.1
	noise.lacunarity = 2
	
	density.octaves = 1
	density.period = 3000
	density.persistence = 0.1
	density.lacunarity = 2

func get_noise_value(Coords : Vector2):
	# Sample
	return noise.get_noise_2d(Coords.x, Coords.y)

func get_density_value(Coords : Vector2):
	# Sample
	return density.get_noise_2d(Coords.x, Coords.y)
	
func combined_noise_value(Coords : Vector2):
	var _density = get_density_value(Coords)
	var _noise = abs(get_noise_value(Coords)) - clamp(_density, 0, 1) * 0.5
	return clamp(_noise, 0, 0.3)

func is_wall(triangle : PoolVector2Array, offset : Vector2):
	var points_inside = []
	for _points in triangle:
		points_inside.append(PerlinNoise.is_inside(_points + offset))
	return points_inside.count(true) == 3
	

func is_inside(Coords : Vector2):
	var value = combined_noise_value(Coords)
	if value < 0.08:
		return false
	return true
