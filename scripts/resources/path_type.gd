extends Resource
class_name PathType

@export var prefab: PackedScene

enum directions {
	Right,
	TopRight,
	TopLeft,
	Left,
	BottomLeft,
	BottomRight,
}
@export_flags("Right", "TopRight", "TopLeft", "Left", "BottomLeft", "BottomRight")
var connections: int:
	set(value):
		connections = value
		num_of_connections = count_set_bits(value)
var num_of_connections: int

func _init(_prefab: PackedScene = null, _connections: int = 0):
	prefab = _prefab
	connections = _connections

static func count_set_bits(n: int) -> int:
	var count = 0
	while n:
		count += n & 1
		n = n >> 1
	return count

static func circular_left_shift(n: int, shift: int, bit_size: int = 32) -> int:
	# Ensure the shift is within the bit size
	shift = shift % bit_size
	
	# Perform the circular left shift
	return ((n << shift) | (n >> (bit_size - shift))) & ((1 << bit_size) - 1)

static func circular_right_shift(n: int, shift: int, bit_size: int = 32) -> int:
	# Ensure the shift is within the bit size
	shift = shift % bit_size
	
	# Perform the circular right shift
	return ((n >> shift) | (n << (bit_size - shift))) & ((1 << bit_size) - 1)
