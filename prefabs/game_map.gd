extends Node3D
class_name GameMap

@export var map_params: HexMapParams

@onready var road_manager = $RoadManager as RoadManager

var map_data: Dictionary = {}
var roads: Dictionary = {}

func _ready():
	generate_map.call_deferred()

func generate_map():
	var base_map_data = HexMapGenerator.generate_map(map_params)
	populate_map(base_map_data)

func populate_map(base_map_data: Dictionary):
	map_data.clear()
	for tile in base_map_data.keys():
		var type = base_map_data[tile]
		var new_tile = create_tile(type, tile)
		add_child(new_tile)
		map_data[tile] = {
			"scene": new_tile,
			"type": type,
		}

func create_tile(type: int, tile: Vector3i) -> Node3D:
	var scenes = TileScenes.TERRAIN_PICKS[type]
	var new_tile = scenes.pick_random().instantiate()
	var point = GameSettings.hex_grid.hex_to_point(Cube.from_vector(tile).to_hex())
	new_tile.position = Vector3(point.x, 0, point.y)
	new_tile.rotation.y = randi_range(0,6) * PI/3
	return new_tile


func _on_hex_map_interaction_place_road(mouse_coords: MouseHexCoordinates):
	road_manager.place_road(mouse_coords, map_data)
