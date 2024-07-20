extends Object
class_name Cube

var q: int
var r: int
var s: int

static var direction_vectors = [
	Vector3i(1,0,-1),
	Vector3i(1,-1,0),
	Vector3i(0,-1,1),
	Vector3i(-1,0,1),
	Vector3i(-1,1,0),
	Vector3i(0,1,-1),
]

static var diagonal_vectors = [
	Vector3i(2,-1,-1),
	Vector3i(1,-2,1),
	Vector3i(-1,-1,2),
	Vector3i(-2,1,1),
	Vector3i(-1,2,-1),
	Vector3i(1,1,-2),
]

func _init(p_q: int, p_r: int, p_s: int):
	if p_q + p_r + p_s != 0:
		printerr("Invalid cube coordinates: Does not add to zero q: %d, r: %d, s: %d" % [p_q, p_r, p_s])
	q = p_q
	r = p_r
	s = p_s

static func from_vector(vec: Vector3i) -> Cube:
	return Cube.new(vec.x, vec.y, vec.z)

static func from_hex(hex: Hex) -> Cube:
	return Cube.new(hex.q, hex.r, -hex.q-hex.r)

static func direction(dir) -> Cube:
	return Cube.from_vector(Cube.direction_vectors[dir])

static func diagonal_direction(dir) -> Cube:
	return Cube.from_vector(Cube.diagonal_vectors[dir])

func to_hex() -> Hex:
	return Hex.new(q,r)

func to_vector3i() -> Vector3i:
	return Vector3i(q,r,s)

func add(vec: Cube) -> Cube:
	return Cube.new(q + vec.q, r + vec.r, s + vec.s)

func subtract(vec: Cube) -> Cube:
	return Cube.new(q - vec.q, r - vec.r, s - vec.s)

func is_equal(vec: Cube) -> bool:
	return q == vec.q and r == vec.r and s == vec.s

func is_zero() -> bool:
	return q == 0 and r == 0 and s == 0

func distance(b: Cube) -> int:
	return self.subtract(b).length()
	
func length() -> int:
	return (abs(q) + abs(r) + abs(s)) / 2

func neighbor(dir) -> Cube:
	return add(Cube.direction(dir))
	
func diagonal_neighbor(dir) -> Cube:
	return add(Cube.diagonal_direction(dir))

func _to_string() -> String:
	return "Cube(q: %d, r: %d, s: %d)" % [q, r, s]

static func cube_linedraw(a: Cube, b: Cube) -> Array:
	return FloatCube.cube_linedraw(FloatCube.from_cube(a), FloatCube.from_cube(b))

static func get_range(center: Cube, N: int) -> Array:
	var results = []
	for pq in range(-N, N+1):
		for pr in range(max(-N, -pq-N), min(N+1, -pq+N+1)):
			var ps = -pq-pr
			results.append(center.add(Cube.new(pq,pr,ps)))
	return results
