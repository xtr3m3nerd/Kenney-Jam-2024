extends Object
class_name FloatCube

var q: float
var r: float
var s: float

func _init(p_q: float, p_r: float, p_s: float):
	if  not is_zero_approx(p_q + p_r + p_s):
		printerr("Invalid cube coordinates: Does not add to zero q: %d, r: %d, s: %d" % [p_q, p_r, p_s])
	q = p_q
	r = p_r
	s = p_s

static func from_vector(vec: Vector3i) -> FloatCube:
	return FloatCube.new(vec.x, vec.y, vec.z)

static func from_float_hex(hex: FloatHex) -> FloatCube:
	return FloatCube.new(hex.q, hex.r, -hex.q-hex.r)

static func from_cube(cube: Cube) -> FloatCube:
	return FloatCube.new(cube.q, cube.r, cube.s)

static func from_hex(hex: Hex) -> FloatCube:
	return FloatCube.new(hex.q, hex.r, -hex.q-hex.r)

func to_float_hex() -> FloatHex:
	return FloatHex.new(q,r)

func add(vec: FloatCube) -> FloatCube:
	return FloatCube.new(q + vec.q, r + vec.r, s + vec.s)

func subtract(vec: FloatCube) -> FloatCube:
	return FloatCube.new(q - vec.q, r - vec.r, s - vec.s)

func distance(b: FloatCube) -> float:
	var vec = self.subtract(b)
	return (abs(vec.q) + abs(vec.r) + abs(vec.s)) / 2

func cube_round() -> Cube:
	var pq = roundf(q)
	var pr = roundf(r)
	var ps = roundf(s)
	
	var q_diff = abs(pq - q)
	var r_diff = abs(pr - r)
	var s_diff = abs(ps - s)
	
	if q_diff > r_diff and q_diff > s_diff:
		pq = -pr-ps
	elif r_diff > s_diff:
		pr = -pq-ps
	else:
		ps = -pq-pr
	
	return Cube.new(pq, pr, ps)
	
static func cube_lerp(a: FloatCube, b: FloatCube, t: float) -> FloatCube:
	return FloatCube.new(
		lerpf(a.q, b.q, t),
		lerpf(a.r, b.r, t),
		lerpf(a.s, b.s, t)
	)

static func cube_linedraw(a: FloatCube, b: FloatCube) -> Array:
	var epsilon = FloatCube.new(1e-6, 2e-6, -3e-6)
	var nudged_b = b.add(epsilon)
	var N = a.distance(nudged_b)
	var results = []
	for i in range(N + 1):
		results.append(FloatCube.cube_lerp(a,nudged_b,1.0/N * i).cube_round())
	return results
