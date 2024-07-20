extends Object
class_name HexMapGenerator

static func generate_map(map_params: HexMapParams) -> Dictionary:
	var map_data = {}
	_initialize_map(map_data, map_params)
	_set_edge_to_deepwater(map_data, map_params)
	_apply_constraints(map_data, map_params)
	return map_data

static func _initialize_map(map_data: Dictionary, map_params: HexMapParams) -> void:
	# TODO - support other map layouts 
	var tiles = Cube.get_range(Cube.new(0, 0, 0), map_params.map_size)
	for tile in tiles:
		map_data[tile.to_vector3i()] = Terrain.Types.UNDECLARED

static func _set_edge_to_deepwater(map_data: Dictionary, map_params: HexMapParams):
	# TODO - move this logic into constraints
	for tile in map_data.keys():
		var cube = Cube.from_vector(tile)
		if cube.distance(Cube.new(0, 0, 0)) == map_params.map_size:
			map_data[tile] = Terrain.Types.DEEPWATER

static func _apply_constraints(map_data: Dictionary, _map_params: HexMapParams):
	var unassigned_tiles = _filter_unassigned(map_data)
	
	var backtrack_counter = 0
	while not unassigned_tiles.is_empty():
		var tile = unassigned_tiles.pop_front()
		var possible_terrains = Terrain.get_possible_terrains(tile, map_data)
		
		if possible_terrains.is_empty():
			backtrack_counter += 1
			if backtrack_counter > 1000:
				printerr("Backtracked too many times")
				map_data[tile] = Terrain.Types.UNDECLARED
				break
			
			_backtrack(tile, map_data)
			unassigned_tiles = _filter_unassigned(map_data)
		else:
			# Assign a random terrain type from the possible options
			map_data[tile] = possible_terrains[randi() % possible_terrains.size()]

static func _filter_unassigned(map_data: Dictionary) -> Array:
	return map_data.keys().filter(func(tile): return map_data[tile] == Terrain.Types.UNDECLARED)

static func _backtrack(tile: Vector3i, map_data: Dictionary):
	# Simple backtracking: reset the current tile and its neighbors
	map_data[tile] = Terrain.Types.UNDECLARED
	var cube = Cube.from_vector(tile)
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_tile = neighbor.to_vector3i()
		# TODO - move this logic into constraints
		if map_data.has(neighbor_tile) and map_data[neighbor_tile] != Terrain.Types.DEEPWATER:
			map_data[neighbor_tile] = Terrain.Types.UNDECLARED
