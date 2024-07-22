extends Node

class_name TradeRouteCalculator

# Constants for route efficiency calculation
const BASE_EFFICIENCY = 100
const DISTANCE_PENALTY = 5
const TERRAIN_PENALTY = {
	"plains": 0,
	"forest": 10,
	"hills": 20,
	"mountains": 40,
	"river": 5
}

# Town class to store town information
class Town:
	var id: int
	var size: String  # "small", "medium", "large"
	var resources: Dictionary  # e.g., {"wheat": 10, "iron": -5} (positive for production, negative for demand)
	
	func _init(p_id: int, p_size: String, p_resources: Dictionary):
		id = p_id
		size = p_size
		resources = p_resources

# Function to calculate trade route efficiency
func calculate_route_efficiency(route: Array, terrain: Array) -> float:
	var efficiency = BASE_EFFICIENCY
	var distance = route.size() - 1
	
	# Apply distance penalty
	efficiency -= distance * DISTANCE_PENALTY
	
	# Apply terrain penalties
	for terrain_type in terrain:
		efficiency -= TERRAIN_PENALTY.get(terrain_type, 0)
	
	return max(efficiency, 0)  # Efficiency can't be negative

# Function to calculate trade route profitability
func calculate_route_profitability(start_town: Town, end_town: Town, efficiency: float) -> int:
	var profitability = 0
	
	# Calculate trade volume based on town sizes
	var trade_volume = get_trade_volume(start_town.size, end_town.size)
	
	# Calculate resource exchange
	for resource in start_town.resources.keys():
		if resource in end_town.resources:
			var exchange = min(abs(start_town.resources[resource]), abs(end_town.resources[resource]))
			profitability += exchange * 10  # Base value per resource unit
	
	# Apply efficiency modifier
	profitability = int(profitability * (efficiency / 100.0) * trade_volume)
	
	return profitability

# Helper function to determine trade volume based on town sizes
func get_trade_volume(size1: String, size2: String) -> float:
	var size_values = {"small": 1, "medium": 1.5, "large": 2}
	return size_values[size1] * size_values[size2]

# Main function to evaluate a trade route
func evaluate_trade_route(route: Array, terrain: Array, towns: Dictionary) -> Dictionary:
	var efficiency = calculate_route_efficiency(route, terrain)
	var start_town = towns[route[0]]
	var end_town = towns[route[-1]]
	var profitability = calculate_route_profitability(start_town, end_town, efficiency)
	
	return {
		"efficiency": efficiency,
		"profitability": profitability,
		"start_town": start_town.id,
		"end_town": end_town.id
	}

# Example usage:
# var calculator = TradeRouteCalculator.new()
# var towns = {
#     0: Town.new(0, "small", {"wheat": 10, "iron": -5}),
#     1: Town.new(1, "medium", {"wheat": -15, "iron": 8})
# }
# var route = [0, 1]  # Town IDs in order
# var terrain = ["plains", "forest", "hills"]
# var result = calculator.evaluate_trade_route(route, terrain, towns)
# print("Route Efficiency: ", result.efficiency)
# print("Route Profitability: ", result.profitability)
