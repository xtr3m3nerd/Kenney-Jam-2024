class_name Terrain

enum Types {
	UNDECLARED,
	HIGH_MOUNTAINS,
	MOUNTAINS,
	FORESTS,
	PLANES,
	DIRT,
	DESERT,
	WATER,
	DEEPWATER,
}

static func get_possible_terrains(tile: Vector3i, map_data: Dictionary) -> Array:
	var possible = Terrain.Types.values()
	possible.erase(Terrain.Types.UNDECLARED)
	possible.erase(Terrain.Types.DEEPWATER)  # DEEPWATER is only for edges
	
	var cube = Cube.from_vector(tile)
	
	# Check neighboring tiles and apply constraints
	for dir in range(6):
		var neighbor = cube.neighbor(dir)
		var neighbor_terrain = map_data.get(neighbor.to_vector3i(), Terrain.Types.UNDECLARED)
		
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
			Terrain.Types.WATER:
				possible.erase(Terrain.Types.HIGH_MOUNTAINS)
				possible.erase(Terrain.Types.MOUNTAINS)
			Terrain.Types.DESERT:
				possible.erase(Terrain.Types.FORESTS)
	
	return possible

static func can_place_road(tile_type: Terrain.Types) -> bool:
	return tile_type not in [
		Terrain.Types.UNDECLARED,
		Terrain.Types.HIGH_MOUNTAINS,
		Terrain.Types.MOUNTAINS,
		Terrain.Types.FORESTS,
		Terrain.Types.WATER,
		Terrain.Types.DEEPWATER
	]


static func get_road_height(tile_type: Terrain.Types) -> float:
	match tile_type:
		Terrain.Types.PLANES, Terrain.Types.DESERT:
			return 0.2
		Terrain.Types.DIRT:
			return 0.1
		_:
			return 0.0

static func get_road_cost(terrain_type: Terrain.Types) -> int:
	match terrain_type:
		Terrain.Types.HIGH_MOUNTAINS: return 5
		Terrain.Types.MOUNTAINS: return 3
		Terrain.Types.FORESTS: return 2
		Terrain.Types.PLANES: return 1
		Terrain.Types.DIRT: return 1
		Terrain.Types.DESERT: return 1
		_: return -1
