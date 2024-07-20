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
	# ISLAND,  # Commented out as it was in the original code
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
