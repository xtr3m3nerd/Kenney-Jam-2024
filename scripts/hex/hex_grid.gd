extends Object
class_name HexGrid

const SQRT_3: float = 1.73205080757

enum Orientation {
	FLAT_TOP,
	POINTY_TOP,
}

enum OffsetCoordinateSystem {
	ODD_R,
	EVEN_R,
	ODD_Q,
	EVEN_Q,
	CUBE,
	AXIAL,
}

@export var orientation: HexGrid.Orientation
@export var size: float
var width: float
var height: float
var horiz: float
var vert: float

func _init(p_orientation: HexGrid.Orientation, p_size: float):
	orientation = p_orientation
	size = p_size
	set_geometry()

func set_geometry():
	match orientation:
		Orientation.FLAT_TOP:
			width = 2 * size
			height = SQRT_3 * size
			horiz = 1.5 * size
			vert = height
		Orientation.POINTY_TOP:
			height = 2 * size
			width = SQRT_3 * size
			horiz = width
			vert = 1.5 * size
			
func corner(center, i) -> Vector2:
	var angle_deg = 60 * i
	if orientation == Orientation.POINTY_TOP:
		angle_deg -= 30
	var angle_rad = deg_to_rad(angle_deg)
	return Vector2(center.x + size * cos(angle_rad), center.y + size * sin(angle_rad))

func hex_to_point(hex: Hex) -> Vector2:
	match orientation:
		Orientation.FLAT_TOP:
			var x = size * 3/2 * hex.q
			var y = size * (SQRT_3 * hex.r + SQRT_3/2 * hex.q)
			return Vector2(x,y)
		Orientation.POINTY_TOP:
			var x = size * (SQRT_3 * hex.q + SQRT_3/2 * hex.r)
			var y = size * 3/2 * hex.r
			return Vector2(x,y)
		_:
			assert(false, "Orientation not implimented")
			return Vector2(0,0)

func cube_to_point(cube: Cube) -> Vector2:
	return hex_to_point(cube.to_hex())

func point_to_hex(point: Vector2) -> Hex:
	return point_to_float_hex(point).hex_round()

func point_to_float_hex(point: Vector2) -> FloatHex:
	match orientation:
		Orientation.FLAT_TOP:
			var q = 2.0/3 * point.x / size
			var r = (-1.0/3 * point.x + SQRT_3/3 * point.y) / size
			return FloatHex.new(q,r)
		Orientation.POINTY_TOP:
			var q = (SQRT_3/3 * point.x - 1.0/3 * point.y) / size
			var r = 2.0/3 * point.y / size
			return FloatHex.new(q,r)
		_:
			assert(false, "Orientation not implimented")
			return FloatHex.new(0,0)
			
func point_to_cube(point: Vector2) -> Cube:
	return point_to_hex(point).to_cube()

func point_to_float_cube(point: Vector2) -> FloatCube:
	return point_to_float_hex(point).to_float_cube()
