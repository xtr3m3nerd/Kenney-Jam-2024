extends Object
class_name FloatHex

var q: float
var r: float

func _init(p_q: float, p_r: float):
	q = p_q
	r = p_r

static func from_vector(vec: Vector2i) -> FloatHex:
	return FloatHex.new(vec.x, vec.y)

static func from_float_cube(cube: FloatCube) -> FloatHex:
	return FloatHex.new(cube.q, cube.r)

static func from_cube(cube: Cube) -> FloatHex:
	return FloatHex.new(cube.q, cube.r)

static func from_hex(hex: Hex) -> FloatHex:
	return FloatHex.new(hex.q, hex.r)

func to_float_cube() -> FloatCube:
	return FloatCube.new(q,r,-q-r)

func add(vec: FloatHex) -> FloatHex:
	return FloatHex.new(q + vec.q, r + vec.r)

func subtract(vec: FloatHex) -> FloatHex:
	return FloatHex.new(q - vec.q, r - vec.r)

func distance(b: FloatHex) -> float:
	var vec = self.subtract(b)
	return (abs(vec.q) + abs(vec.q + vec.r) + abs(vec.r)) / 2

func hex_round() -> Hex:
	return to_float_cube().cube_round().to_hex()
	
static func hex_lerp(a: FloatHex, b: FloatHex, t: float) -> FloatHex:
	return FloatHex.new(
		lerpf(a.q, b.q, t),
		lerpf(a.r, b.r, t)
	)

static func hex_linedraw(a: FloatHex, b: FloatHex) -> Array:
	var results = []
	var cube_results = FloatCube.cube_linedraw(a.to_float_cube(), b.to_float_cube())
	for result in cube_results:
		results.append(result.to_hex())
	return results
