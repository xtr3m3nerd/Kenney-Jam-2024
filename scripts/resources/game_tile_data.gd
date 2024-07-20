extends Resource
class_name GameTileData

enum BaseTerrain {
	DIRT,
	GRASS,
	STONE,
	DESERT,
	RIVER,
	OCEAN,
}

@export var can_build_road: bool
@export var base_terrain: BaseTerrain
@export var display_name: String
@export var resources_produced: Array[GameResource] 
@export var resources_requested: Array[GameResource]
@export var prefab: PackedScene
