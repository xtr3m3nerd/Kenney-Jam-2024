extends Resource
class_name HexMapParams

enum MapShape {
	HEXAGON,
	RECTANGLE,
	RHOMBUS,
	DOWN_TRIANGLE,
	UP_TRIANGLE,
}

@export var map_size: int
#@export var map_shape: MapShape

func _init(_map_size: int = 5): #, _map_shape: MapShape = MapShape.HEXAGON):
	map_size = _map_size
	#map_shape = _map_shape
