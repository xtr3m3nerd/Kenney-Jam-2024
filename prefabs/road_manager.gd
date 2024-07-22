extends Node3D
class_name RoadManager

@export var road_tiles: Array[PathType]
var connection_lookup: Dictionary = {}

var road_network: HexGraph
var roads: Dictionary = {}

@onready var resource_manager: ResourceManager = get_tree().get_first_node_in_group("resource_manager")

func _ready():
	connection_lookup = build_connection_lookup(road_tiles)
	road_network = HexGraph.new()

func build_connection_lookup(path_tiles: Array[PathType]):
	var results = {}
	results[0] = []
	for tile in path_tiles:
		if not results.has(tile.num_of_connections):
			results[tile.num_of_connections] = []
		results[tile.num_of_connections].append(tile)
		if tile.num_of_connections == 1:
			results[0].append(tile)
	return results

func place_road(mouse_coords: MouseHexCoordinates, map_data: Dictionary):
	var tile = map_data.get(mouse_coords.tile.to_vector3i(), null)
	
	if not tile:
		return
	if not Terrain.can_place_road(tile["type"]):
		return
	if not resource_manager.can_afford_road(tile["type"]):
		return
	
	var redraw_list: Array[Cube] = []
	
	if road_network.has_hex_node(mouse_coords.tile):
		# Check to see if you are making a new connection
		var connection = mouse_coords.tile.add(mouse_coords.nearest_neighbor)
		if not road_network.has_hex_node(connection):
			return
		if road_network.has_edge(mouse_coords.tile,connection):
			return
		road_network.add_edge(connection,mouse_coords.tile)
		redraw_list.append(mouse_coords.tile)
		redraw_list.append(connection)
	else:
		var nearby = 0
		for dir in range(6):
			var neighbor = mouse_coords.tile.neighbor(dir)
			if road_network.has_hex_node(neighbor):
				nearby += 1
				road_network.add_edge(mouse_coords.tile, neighbor)
				redraw_list.append(neighbor)
		
		if nearby == 0:
			road_network.add_node(mouse_coords.tile)
		redraw_list.append(mouse_coords.tile)
	
	if not resource_manager.build_road(tile["type"]):
		printerr("Opps couldnt charge you for road for some reason... must be free")
	redraw_tiles(redraw_list, map_data, mouse_coords)

func redraw_tiles(redraw_list: Array[Cube], map_data: Dictionary, mouse_coords: MouseHexCoordinates):
	for tile in redraw_list:
		var point = GameSettings.hex_grid.cube_to_point(tile)
		var tile_data = map_data.get(tile.to_vector3i(), null)
		var spawn_point = Vector3(point.x, Terrain.get_road_height(tile_data["type"]), point.y)
		
		if not tile:
			return
		
		if roads.has(tile.to_vector3i()):
			var old_road = roads.get(tile.to_vector3i())
			roads.erase(tile.to_vector3i())
			old_road.queue_free()
		
		var hex_node = road_network.get_hex_node(tile)
		var picked_road: PathOrientation = pick_road(get_neighbor_flags(hex_node), mouse_coords)
		if picked_road == null:
			return
		var road = picked_road.type.prefab.instantiate()
		road.position = spawn_point
		road.rotation.y = picked_road.dir * PI/3 + PI
		roads[tile.to_vector3i()] = road
		add_child(road)

func get_neighbor_flags(hex_node: HexGraph.HexNode) -> int:
	var flags = 0
	for edge in hex_node.edges:
		var dir_vec = hex_node.get_dir(edge)
		if dir_vec == Vector3i.ZERO:
			printerr("Improper edge: ", edge)
			continue
		var dir = Cube.direction_vectors.find(dir_vec)
		if dir == -1:
			printerr("Invalid dir_vec: ", dir_vec)
			continue
		flags |= 1 << dir
	return flags

func pick_road(neighbor_flags: int, mouse_coords: MouseHexCoordinates) -> PathOrientation:
	var num_connections = PathType.count_set_bits(neighbor_flags)
	var path_types = connection_lookup.get(num_connections, [])
	if path_types.is_empty():
		printerr("No paths have %d connections")
		return null
	# TODO - write function to check for neighboring buildings
	var num_building_neighbors = 0
	
	if num_building_neighbors == 0:
		var paths_with_none_rule = path_types.filter(func(path_type): return path_type.next_to_buildings == PathType.BuildingNeighborRules.NONE)
		if not paths_with_none_rule.is_empty():
			path_types = paths_with_none_rule
	elif num_building_neighbors == 1:
		var paths_with_one_rule = path_types.filter(func(path_type): return path_type.next_to_buildings == PathType.BuildingNeighborRules.ONE)
		if not paths_with_one_rule.is_empty():
			path_types = paths_with_one_rule
	else:
		var paths_with_multiple_rule = path_types.filter(func(path_type): return path_type.next_to_buildings == PathType.BuildingNeighborRules.MULTIPLE)
		if not paths_with_multiple_rule.is_empty():
			path_types = paths_with_multiple_rule
	
	if num_connections == 0:
		return PathOrientation.new(path_types[0], mouse_coords.nearest_neighbor_dir)
	for path_type in path_types:
		if num_building_neighbors == 0 and not path_type.next_to_buildings == PathType.BuildingNeighborRules.NONE:
			continue
		if num_building_neighbors == 1 and not path_type.next_to_buildings == PathType.BuildingNeighborRules.ONE:
			continue
		for i in range(6):
			if neighbor_flags == PathType.circular_left_shift(path_type.connections, i, 6):
				return PathOrientation.new(path_type,i)
	printerr("Unable to find connection with following flags %X" % neighbor_flags)
	return null


func get_roads() -> Dictionary:
	return roads

func clear_roads() -> void:
	roads.clear()
	for child in get_children():
		child.queue_free()

func remove_road(tile_coord: Vector3i) -> void:
	if roads.has(tile_coord):
		var road = roads.get(tile_coord)
		road.queue_free()
		roads.erase(tile_coord)
