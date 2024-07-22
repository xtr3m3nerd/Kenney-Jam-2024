extends Node3D
class_name HexMapInteraction

signal place_road(mouse_coords: MouseHexCoordinates)

@onready var placeholder = $Placeholder

func _ready():
	hide_placeholder()
	
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		handle_mouse_motion(event)
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		handle_mouse_click(event)

func handle_mouse_motion(_event: InputEventMouseMotion) -> void:
	var mouse_coords = get_mouse_hex_coordinates()
	if mouse_coords:
		update_placeholder(mouse_coords.tile)
	else:
		hide_placeholder()

func handle_mouse_click(_event: InputEventMouseButton) -> void:
	var mouse_coords = get_mouse_hex_coordinates()
	if mouse_coords:
		place_road.emit(mouse_coords)

func get_mouse_hex_coordinates() -> MouseHexCoordinates:
	var intersection = get_mouse_intersection()
	if intersection:
		var intersec_2d = Vector2(intersection.x, intersection.z)
		var pos = GameSettings.hex_grid.point_to_float_cube(intersec_2d)
		return MouseHexCoordinates.new(pos)
	return null

func get_mouse_intersection() -> Vector3:
	var camera = get_viewport().get_camera_3d()
	if not camera:
		print("No active camera found")
		return Vector3.ZERO
	
	var mouse_pos = get_viewport().get_mouse_position()
	var ray_start = camera.project_ray_origin(mouse_pos)
	var ray_end = ray_start + camera.project_ray_normal(mouse_pos) * 1000
	
	var plane = Plane(Vector3.UP, 0)  # X/Z plane at Y=0
	
	var intersection = plane.intersects_ray(ray_start, ray_end)
	return intersection if intersection else Vector3.ZERO

func update_placeholder(tile_coord: Cube) -> void:
	placeholder.show()
	var placeholder_point = GameSettings.hex_grid.hex_to_point(tile_coord.to_hex())
	placeholder.position = Vector3(placeholder_point.x, 0, placeholder_point.y)

func hide_placeholder() -> void:
	placeholder.hide()
