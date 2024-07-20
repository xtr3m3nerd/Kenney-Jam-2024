extends Node3D

@export var base_tile: PackedScene
@export var terrain_tiles: Array[PackedScene]
@onready var mesh_instance_3d = $MeshInstance3D
@onready var placeholder = $Placeholder

@export var tile_size: float = 1.0
@export var map_size: int = 15

var hex_grid: HexGrid

var tile_dictionary: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	hex_grid = HexGrid.new(HexGrid.Orientation.POINTY_TOP, tile_size/HexGrid.SQRT_3)
	generate_map()
	#var tiles = Cube.get_range(Cube.new(0,0,0), map_size)
	#print(tiles.size())
	#for tile in tiles:
		#var new_tile = terrain_tiles.pick_random().instantiate()
		#var point = hex_grid.hex_to_point(tile.to_hex())
		#new_tile.position = Vector3(point.x, 0, point.y)
		#new_tile.rotation.y = randi_range(0,6) * PI/3
		#add_child(new_tile)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		var intersection = get_mouse_intersection()
		if intersection:
			#mesh_instance_3d.show()
			placeholder.show()
			mesh_instance_3d.position = intersection
			var intersec_2d = Vector2(intersection.x, intersection.z)
			var tile_coord = hex_grid.point_to_hex(intersec_2d).to_cube()
			var placeholder_point = hex_grid.hex_to_point(tile_coord.to_hex())
			placeholder.position = Vector3(placeholder_point.x, 0, placeholder_point.y)
			#var tile_coords_str = "(%f, %f, %f)" % [tile_coord.q, tile_coord.r, tile_coord.s]
			#print("Intersection point: ", intersection, " -> ", tile_coords_str)
		else:
			mesh_instance_3d.hide()
			placeholder.hide()

func get_mouse_intersection():
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("No active camera found")
		return null
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_start + camera.project_ray_normal(mouse_pos) * 1000
	
	var plane = Plane(Vector3.UP, 0)  # X/Z plane at Y=0
	
	return plane.intersects_ray(ray_start, ray_end)

const PLACEHOLDER_TILE = preload("res://prefabs/tiles/placeholder_tile.tscn")
const DIRT = preload("res://prefabs/tiles/terrain/dirt.tscn")
const DIRT_LUMBER = preload("res://prefabs/tiles/terrain/dirt_lumber.tscn")
const GRASS = preload("res://prefabs/tiles/terrain/grass.tscn")
const GRASS_FOREST = preload("res://prefabs/tiles/terrain/grass_forest.tscn")
const GRASS_HILL = preload("res://prefabs/tiles/terrain/grass_hill.tscn")
const SAND = preload("res://prefabs/tiles/terrain/sand.tscn")
const SAND_DESERT = preload("res://prefabs/tiles/terrain/sand_desert.tscn")
const SAND_ROCKS = preload("res://prefabs/tiles/terrain/sand_rocks.tscn")
const STONE = preload("res://prefabs/tiles/terrain/stone.tscn")
const STONE_HILL = preload("res://prefabs/tiles/terrain/stone_hill.tscn")
const STONE_MOUNTAIN = preload("res://prefabs/tiles/terrain/stone_mountain.tscn")
const STONE_ROCKS = preload("res://prefabs/tiles/terrain/stone_rocks.tscn")
const WATER = preload("res://prefabs/tiles/terrain/water.tscn")
const WATER_ISLAND = preload("res://prefabs/tiles/terrain/water_island.tscn")
const WATER_ROCKS = preload("res://prefabs/tiles/terrain/water_rocks.tscn")

enum TerrainTypes {
	UNDECLARED,
	HIGH_MOUNTAINS,
	MOUNTAINS,
	FORESTS,
	PLANES,
	DIRT,
	DESERT,
	WATER,
	DEEPWATER,
#	ISLAND,
}

var terrain_picks: Array = [
	[PLACEHOLDER_TILE],
	[STONE_MOUNTAIN],
	[STONE_HILL,STONE_ROCKS, GRASS_HILL],
	[GRASS_FOREST],
	[GRASS],
	[DIRT, DIRT_LUMBER],
	[SAND, SAND_DESERT, SAND_ROCKS],
	[WATER, WATER, WATER, WATER, WATER, WATER, WATER_ROCKS],
	[WATER],
#	[WATER_ISLAND],
]

var map_gen: Dictionary = {}

func generate_map():
	# Initialize the map with UNDECLARED terrain
	var tiles = Cube.get_range(Cube.new(0, 0, 0), map_size)
	for tile in tiles:
		map_gen[tile.to_vector3i()] = TerrainTypes.UNDECLARED
	
	# Set the edge tiles to DEEPWATER
	set_edge_to_deepwater()
	
	# Apply constraints and generate terrain
	apply_constraints()
	populate_map()

func set_edge_to_deepwater():
	for tile in map_gen.keys():
		var cube = Cube.from_vector(tile)
		if cube.distance(Cube.new(0, 0, 0)) == map_size:
			map_gen[tile] = TerrainTypes.DEEPWATER

func apply_constraints():
	var unassigned_tiles = filter_unassigned()
	
	var backtrack_counter = 0
	while not unassigned_tiles.is_empty():
		var tile = unassigned_tiles.pop_front()
		var possible_terrains = get_possible_terrains(tile)
		
		if possible_terrains.is_empty():
			# Backtrack if no valid terrain types are available
			backtrack_counter += 1
			if backtrack_counter > 1000:
				printerr("Backtracked too many times")
				map_gen[tile] = TerrainTypes.UNDECLARED
				break
			
			backtrack(tile)
			unassigned_tiles = filter_unassigned()
		else:
			# Assign a random terrain type from the possible options
			map_gen[tile] = possible_terrains[randi() % possible_terrains.size()]

func filter_unassigned() -> Array:
	return map_gen.keys().filter(func(tile): return map_gen[tile] == TerrainTypes.UNDECLARED)
	
func get_possible_terrains(tile: Vector3i) -> Array:
	var possible = TerrainTypes.values()
	possible.erase(TerrainTypes.UNDECLARED)
	possible.erase(TerrainTypes.DEEPWATER)  # DEEPWATER is only for edges
	
	var cube = Cube.from_vector(tile)
	
	# Check neighboring tiles and apply constraints
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_terrain = map_gen.get(neighbor.to_vector3i(), TerrainTypes.UNDECLARED)
		
		match neighbor_terrain:
			TerrainTypes.HIGH_MOUNTAINS:
				possible.erase(TerrainTypes.FORESTS)
				possible.erase(TerrainTypes.PLANES)
				possible.erase(TerrainTypes.DIRT)
				possible.erase(TerrainTypes.WATER)
			TerrainTypes.DEEPWATER:
				possible.erase(TerrainTypes.HIGH_MOUNTAINS)
				possible.erase(TerrainTypes.MOUNTAINS)
				possible.erase(TerrainTypes.FORESTS)
				possible.erase(TerrainTypes.PLANES)
				possible.erase(TerrainTypes.DIRT)
				possible.erase(TerrainTypes.DESERT)
			#TerrainTypes.ISLAND:
				#possible.erase(TerrainTypes.HIGH_MOUNTAINS)
				#possible.erase(TerrainTypes.MOUNTAINS)
				#possible.erase(TerrainTypes.FORESTS)
				#possible.erase(TerrainTypes.PLANES)
				#possible.erase(TerrainTypes.DIRT)
				#possible.erase(TerrainTypes.DESERT)
				#possible.erase(TerrainTypes.ISLAND)
				#possible.erase(TerrainTypes.WATER)
			TerrainTypes.WATER:
				possible.erase(TerrainTypes.HIGH_MOUNTAINS)
				possible.erase(TerrainTypes.MOUNTAINS)
			TerrainTypes.DESERT:
				possible.erase(TerrainTypes.FORESTS)
	
	return possible

func backtrack(tile: Vector3i):
	# Simple backtracking: reset the current tile and its neighbors
	map_gen[tile] = TerrainTypes.UNDECLARED
	var cube = Cube.from_vector(tile)
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_tile = neighbor.to_vector3i()
		if map_gen.has(neighbor_tile) and map_gen[neighbor_tile] != TerrainTypes.DEEPWATER:
			map_gen[neighbor_tile] = TerrainTypes.UNDECLARED

func populate_map():
	tile_dictionary.clear()
	for tile in map_gen.keys():
		var cube = Cube.from_vector(tile)
		var type = map_gen.get(tile, TerrainTypes.UNDECLARED)
		var scenes = terrain_picks[type]
		var new_tile = scenes.pick_random().instantiate()
		var point = hex_grid.hex_to_point(cube.to_hex())
		new_tile.position = Vector3(point.x, 0, point.y)
		new_tile.rotation.y = randi_range(0,6) * PI/3
		add_child(new_tile)
		tile_dictionary[tile] = new_tile
