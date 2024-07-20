extends Node3D

@export var cell_number: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in range(6):
		var cell = cell_number.instantiate() as Label3D
		cell.text = str(i)
		var point = GameSettings.hex_grid.hex_to_point(Hex.direction(i))
		cell.position.x = point.x
		cell.position.z = point.y
		add_child(cell)
