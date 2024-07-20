class_name TileScenes

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

const TERRAIN_PICKS = [
	[PLACEHOLDER_TILE],
	[STONE_MOUNTAIN],
	[STONE_HILL, STONE_ROCKS, GRASS_HILL],
	[GRASS_FOREST],
	[GRASS],
	[DIRT, DIRT_LUMBER],
	[SAND, SAND_DESERT, SAND_ROCKS],
	[WATER, WATER, WATER, WATER, WATER, WATER, WATER_ROCKS],
	[WATER],
	# [WATER_ISLAND],  # Commented out as it was in the original code
]
