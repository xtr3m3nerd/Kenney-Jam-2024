extends Node3D

@export var base_tile: PackedScene
@export var road_tile: PackedScene
@export var terrain_tiles: Array[PackedScene]
@onready var placeholder = $Placeholder

@export var tile_size: float = 1.0
@export var map_size: int = 15

var hex_grid: HexGrid
var tile_dictionary: Dictionary = {}
var roads: Dictionary = {}
var map_gen: Dictionary = {}

func _ready():
	hex_grid = HexGrid.new(HexGrid.Orientation.POINTY_TOP, tile_size/HexGrid.SQRT_3)
	generate_map()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_mouse_click(event)

func handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var tile_coord = get_tile_under_mouse()
	if tile_coord:
		update_placeholder(tile_coord)
	else:
		hide_placeholder()

func handle_mouse_click(event: InputEventMouseButton) -> void:
	var tile_coord = get_tile_under_mouse()
	if tile_coord:
		place_road(tile_coord)

func update_placeholder(tile_coord: Cube) -> void:
	placeholder.show()
	var placeholder_point = hex_grid.hex_to_point(tile_coord.to_hex())
	placeholder.position = Vector3(placeholder_point.x, 0, placeholder_point.y)

func hide_placeholder() -> void:
	placeholder.hide()

func place_road(tile_coord: Cube) -> void:
	var point = hex_grid.hex_to_point(tile_coord.to_hex())
	var spawn_point = Vector3(point.x, 0, point.y)
	var tile_type = map_gen.get(tile_coord.to_vector3i(), Terrain.Types.UNDECLARED)
	
	if not can_place_road(tile_type):
		return
	
	spawn_point.y += get_road_height(tile_type)
	
	var road = road_tile.instantiate()
	road.position = spawn_point
	add_child(road)
	roads[tile_coord.to_vector3i()] = road

func can_place_road(tile_type: int) -> bool:
	return tile_type not in [
		Terrain.Types.UNDECLARED,
		Terrain.Types.HIGH_MOUNTAINS,
		Terrain.Types.MOUNTAINS,
		Terrain.Types.FORESTS,
		Terrain.Types.WATER,
		Terrain.Types.DEEPWATER
	]

func get_road_height(tile_type: int) -> float:
	match tile_type:
		Terrain.Types.PLANES, Terrain.Types.DESERT:
			return 0.2
		Terrain.Types.DIRT:
			return 0.1
		_:
			return 0.0

func get_tile_under_mouse():
	var intersection = get_mouse_intersection()
	if intersection:
		var intersec_2d = Vector2(intersection.x, intersection.z)
		return hex_grid.point_to_hex(intersec_2d).to_cube()
	return null

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


func generate_map():
	initialize_map()
	set_edge_to_deepwater()
	apply_constraints()
	populate_map()

func initialize_map() -> void:
	var tiles = Cube.get_range(Cube.new(0, 0, 0), map_size)
	for tile in tiles:
		map_gen[tile.to_vector3i()] = Terrain.Types.UNDECLARED
		
func set_edge_to_deepwater():
	for tile in map_gen.keys():
		var cube = Cube.from_vector(tile)
		if cube.distance(Cube.new(0, 0, 0)) == map_size:
			map_gen[tile] = Terrain.Types.DEEPWATER

func apply_constraints():
	var unassigned_tiles = filter_unassigned()
	
	var backtrack_counter = 0
	while not unassigned_tiles.is_empty():
		var tile = unassigned_tiles.pop_front()
		var possible_terrains = get_possible_terrains(tile)
		
		if possible_terrains.is_empty():
			backtrack_counter += 1
			if backtrack_counter > 1000:
				printerr("Backtracked too many times")
				map_gen[tile] = Terrain.Types.UNDECLARED
				break
			
			backtrack(tile)
			unassigned_tiles = filter_unassigned()
		else:
			# Assign a random terrain type from the possible options
			map_gen[tile] = possible_terrains[randi() % possible_terrains.size()]

func filter_unassigned() -> Array:
	return map_gen.keys().filter(func(tile): return map_gen[tile] == Terrain.Types.UNDECLARED)
	
func get_possible_terrains(tile: Vector3i) -> Array:
	var possible = Terrain.Types.values()
	possible.erase(Terrain.Types.UNDECLARED)
	possible.erase(Terrain.Types.DEEPWATER)  # DEEPWATER is only for edges
	
	var cube = Cube.from_vector(tile)
	
	# Check neighboring tiles and apply constraints
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_terrain = map_gen.get(neighbor.to_vector3i(), Terrain.Types.UNDECLARED)
		
		match neighbor_terrain:
			Terrain.Types.HIGH_MOUNTAINS:
				possible.erase(Terrain.Types.FORESTS)
				possible.erase(Terrain.Types.PLANES)
				possible.erase(Terrain.Types.DIRT)
				possible.erase(Terrain.Types.WATER)
			Terrain.Types.DEEPWATER:
				possible.erase(Terrain.Types.HIGH_MOUNTAINS)
				possible.erase(Terrain.Types.MOUNTAINS)
				possible.erase(Terrain.Types.FORESTS)
				possible.erase(Terrain.Types.PLANES)
				possible.erase(Terrain.Types.DIRT)
				possible.erase(Terrain.Types.DESERT)
			#Terrain.Types.ISLAND:
				#possible.erase(Terrain.Types.HIGH_MOUNTAINS)
				#possible.erase(Terrain.Types.MOUNTAINS)
				#possible.erase(Terrain.Types.FORESTS)
				#possible.erase(Terrain.Types.PLANES)
				#possible.erase(Terrain.Types.DIRT)
				#possible.erase(Terrain.Types.DESERT)
				#possible.erase(Terrain.Types.ISLAND)
				#possible.erase(Terrain.Types.WATER)
			Terrain.Types.WATER:
				possible.erase(Terrain.Types.HIGH_MOUNTAINS)
				possible.erase(Terrain.Types.MOUNTAINS)
			Terrain.Types.DESERT:
				possible.erase(Terrain.Types.FORESTS)
	
	return possible

func backtrack(tile: Vector3i):
	# Simple backtracking: reset the current tile and its neighbors
	map_gen[tile] = Terrain.Types.UNDECLARED
	var cube = Cube.from_vector(tile)
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_tile = neighbor.to_vector3i()
		if map_gen.has(neighbor_tile) and map_gen[neighbor_tile] != Terrain.Types.DEEPWATER:
			map_gen[neighbor_tile] = Terrain.Types.UNDECLARED

func populate_map():
	tile_dictionary.clear()
	for tile in map_gen.keys():
		var cube = Cube.from_vector(tile)
		var type = map_gen.get(tile, Terrain.Types.UNDECLARED)
		var scenes = TileScenes.TERRAIN_PICKS[type]
		var new_tile = scenes.pick_random().instantiate()
		var point = hex_grid.hex_to_point(cube.to_hex())
		new_tile.position = Vector3(point.x, 0, point.y)
		new_tile.rotation.y = randi_range(0,6) * PI/3
		add_child(new_tile)
		tile_dictionary[tile] = new_tile
