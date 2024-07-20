extends Object
class_name HexGraph

class HexNode:
	var cube: Cube
	var edges: Array[HexEdge] = []
	
	func _init(p_cube: Cube):
		cube = p_cube
	
	func get_dir(edge: HexEdge) -> Vector3i:
		var dir = 0
		if edge.from_node == self:
			dir = 1
		elif edge.to_node == self:
			dir = -1
		else:
			return Vector3i.ZERO
		return edge.get_dir() * dir
		
	func _to_string() -> String:
		return "HexNode(cube: %s, edges: %d)" % [cube, edges.size()]

class HexEdge:
	var from_node: HexNode
	var to_node: HexNode
	
	func _init(p_from: HexNode, p_to: HexNode):
		from_node = p_from
		to_node = p_to
	
	func get_dir() -> Vector3i:
		return from_node.cube.subtract(to_node.cube).to_vector3i()
		
	func _to_string() -> String:
		return "HexEdge(from: %s, to: %s, dir: %s)" % [from_node, to_node, get_dir()]

var nodes: Dictionary = {}  # Cube coordinates (Vector3i) to HexNode
var edges: Array[HexEdge] = []

func add_node(cube: Cube) -> HexNode:
	var coord = cube.to_vector3i()
	if coord in nodes:
		return nodes[coord]
	var node = HexNode.new(cube)
	nodes[coord] = node
	return node

func add_edge(from_cube: Cube, to_cube: Cube) -> HexEdge:
	var from_node = add_node(from_cube)
	var to_node = add_node(to_cube)
	
	# Check if nodes are adjacent
	if from_cube.distance(to_cube) != 1:
		printerr("Cannot add edge: Nodes are not adjacent")
		return null
	
	# Check if edge already exists
	for edge in from_node.edges:
		if edge.to_node == to_node:
			return edge
	
	var edge = HexEdge.new(from_node, to_node)
	from_node.edges.append(edge)
	to_node.edges.append(edge)
	edges.append(edge)
	return edge

func get_hex_node(cube: Cube) -> HexNode:
	return nodes.get(cube.to_vector3i())

func has_hex_node(cube: Cube) -> bool:
	return cube.to_vector3i() in nodes

func remove_node(cube: Cube) -> void:
	var node = get_hex_node(cube)
	if node:
		# Remove all edges connected to this node
		for edge in node.edges:
			remove_edge(edge)
		nodes.erase(cube.to_vector3i())

func remove_edge(edge: HexEdge) -> void:
	edge.from_node.edges.erase(edge)
	edge.to_node.edges.erase(edge)
	edges.erase(edge)

func get_neighbors(cube: Cube) -> Array[HexNode]:
	var node = get_hex_node(cube)
	if not node:
		return []
	return node.edges.map(func(edge): return edge.to_node if edge.from_node == node else edge.from_node)

func find_path(start_cube: Cube, end_cube: Cube) -> Array:
	var start_node = get_hex_node(start_cube)
	var end_node = get_hex_node(end_cube)
	if not start_node or not end_node:
		return []
	
	var visited = {}
	var path = []
	
	if _dfs_recursive(start_node, end_node, visited, path):
		return path.map(func(node): return node.cube)
	else:
		return []

func _dfs_recursive(current_node: HexNode, end_node: HexNode, visited: Dictionary, path: Array) -> bool:
	visited[current_node] = true
	path.append(current_node)
	
	if current_node == end_node:
		return true
	
	for edge in current_node.edges:
		var next_node = edge.to_node if edge.from_node == current_node else edge.from_node
		if next_node not in visited:
			if _dfs_recursive(next_node, end_node, visited, path):
				return true
	
	path.pop_back()
	return false

func has_edge(from_cube: Cube, to_cube: Cube) -> bool:
	var from_node = get_hex_node(from_cube)
	var to_node = get_hex_node(to_cube)
	
	if not from_node or not to_node:
		return false
	
	for edge in from_node.edges:
		if edge.to_node == to_node or edge.from_node == to_node:
			return true
	
	return false
