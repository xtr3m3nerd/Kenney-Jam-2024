extends Object
class_name Hex

# https://www.redblobgames.com/grids/hexagons/
var q: int
var r: int

static var direction_vectors = [
	Vector2i(1,0),
	Vector2i(1,-1),
	Vector2i(0,-1),
	Vector2i(-1,0),
	Vector2i(-1,1),
	Vector2i(0,1,),
]

static var diagonal_vectors = [
	Vector2i(2,-1),
	Vector2i(1,-2),
	Vector2i(-1,-1),
	Vector2i(-2,1),
	Vector2i(-1,2),
	Vector2i(1,1),
]

func _init(p_q: int, p_r: int):
	q = p_q
	r = p_r

static func from_vector(vec: Vector2i) -> Hex:
	return Hex.new(vec.x, vec.y)

static func from_cube(cube: Cube) -> Hex:
	return Hex.new(cube.q, cube.r)

static func direction(dir) -> Hex:
	return Hex.from_vector(Hex.direction_vectors[dir])

static func diagonal_direction(dir) -> Hex:
	return Hex.from_vector(Hex.diagonal_vectors[dir])

func to_cube() -> Cube:
	return Cube.new(q,r,-q-r)

func add(vec: Hex) -> Hex:
	return Hex.new(q + vec.q, r + vec.r)

func subtract(vec: Hex) -> Hex:
	return Hex.new(q - vec.q, r - vec.r)

func is_equal(vec: Hex) -> bool:
	return q == vec.q and r == vec.r

func is_zero() -> bool:
	return q == 0 and r == 0

func distance(b: Hex) -> int:
	return self.subtract(b).length()

func length() -> int:
	return (abs(q) + abs(q + r) + abs(r)) / 2
	
func neighbor(dir) -> Hex:
	return add(Hex.direction(dir))
	
func diagonal_neighbor(dir) -> Hex:
	return add(Hex.diagonal_direction(dir))

func _to_string() -> String:
	return "Hex(q: %d, r: %d)" % [q, r]

static func get_range(center: Hex, N: int) -> Array:
	var results = []
	for pq in range(-N, N+1):
		for pr in range(max(-N, -pq-N), min(N, -pq+N)):
			results.append(center.add(Hex.new(pq,pr)))
	return results
