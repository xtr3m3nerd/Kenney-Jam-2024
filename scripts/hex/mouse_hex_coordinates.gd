extends Object
class_name MouseHexCoordinates

var pos: FloatCube
var tile: Cube
var diff: FloatCube
var nearest_neighbor: Cube
var nearest_neighbor_dir: int

func _init(_pos: FloatCube):
	pos = _pos
	tile = pos.cube_round()
	diff = pos.subtract(FloatCube.from_cube(tile))
	nearest_neighbor = diff.normalize().cube_round()
	nearest_neighbor_dir = Cube.direction_vectors.find(nearest_neighbor.to_vector3i())
