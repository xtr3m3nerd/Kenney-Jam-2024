extends Resource
class_name GameResource

enum Type {
	GOLD,
	ORE,
	METAL,
	WEAPONS,
	LUMBER,
	FOOD,
}

@export var type: Type
@export var amount: int
