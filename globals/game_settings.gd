extends Node

@export var tile_size: float = 1.0

var hex_grid: HexGrid

func _ready():
	hex_grid = HexGrid.new(HexGrid.Orientation.POINTY_TOP, tile_size/HexGrid.SQRT_3)
