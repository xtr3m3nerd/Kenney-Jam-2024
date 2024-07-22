extends Label


@onready var resource_manager: ResourceManager = get_tree().get_first_node_in_group("resource_manager")

func _ready():
	resource_manager.resource_changed.connect(_on_resource_changed)
	update_text(resource_manager.get_resource("gold"))

func _on_resource_changed(resource_name: String, amount: int):
	if resource_name == "gold":
		update_text(amount)

func update_text(amount: int):
	text = "Gold: %d" % amount
