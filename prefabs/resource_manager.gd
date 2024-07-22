extends Node
class_name ResourceManager

@export var starting_gold: int = 100
var resources = {}

signal resource_changed(resource_name: String, amount: int)

func _ready():
	add_resource("gold", starting_gold)

func add_resource(resource_name: String, amount: int) -> void:
	if resource_name in resources:
		resources[resource_name] += amount
	else:
		resources[resource_name] = amount
	
	emit_signal("resource_changed", resource_name, resources[resource_name])

func subtract_resource(resource_name: String, amount: int) -> bool:
	if resource_name in resources and resources[resource_name] >= amount:
		resources[resource_name] -= amount
		emit_signal("resource_changed", resource_name, resources[resource_name])
		return true
	return false

func get_resource(resource_name: String) -> int:
	return resources.get(resource_name, 0)

func has_enough_resource(resource_name: String, amount: int) -> bool:
	return get_resource(resource_name) >= amount

func process_trade_income(income: int) -> void:
	add_resource("gold", income)

func can_afford_road(terrain_type: Terrain.Types) -> bool:
	var cost = Terrain.get_road_cost(terrain_type)
	if cost < 0:
		printerr("Checking price on invalid terrain type", terrain_type)
		return false
	return has_enough_resource("gold", cost)
	
func build_road(terrain_type: Terrain.Types) -> bool:
	var cost = Terrain.get_road_cost(terrain_type)
	if cost < 0:
		return false
	return subtract_resource("gold", cost)

