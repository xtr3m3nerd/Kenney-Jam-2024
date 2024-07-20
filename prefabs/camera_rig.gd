extends Marker3D

# Camera movement speed
@export var min_speed = 5.0
@export var max_speed = 20.0
# Camera rotation speed
@export var rotation_speed = 2.0
# Camera zoom speed
@export var zoom_speed = 3.0
# Edge scrolling threshold
@export var edge_threshold = 2

@onready var vertical_pivot = $VerticalPivot
@onready var camera_3d = $VerticalPivot/Camera3D

# Camera's focal point
var focal_point = Vector3.ZERO
# Current zoom level
var zoom_level = 10.0
# Minimum and maximum zoom levels
var min_zoom = 5.0
var max_zoom = 20.0
var zoom_increments = 2.5
# Vertical rotation limits (in radians)
var min_vertical_angle = deg_to_rad(-85) # -45 degrees
var max_vertical_angle = deg_to_rad(-15)   # 45 degrees
# Current vertical rotation
var vertical_rotation = 0.0

var velocity: Vector3 = Vector3.ZERO

func _ready():
	camera_3d.position.z = zoom_level
	pass

func _process(delta):
	var input_dir = Input.get_vector("move_left", "move_right", "move_foward", "move_backward")
	var edge_movement_dir = get_edge_movement_dir()
	var move_dir = input_dir if not input_dir.is_zero_approx() else edge_movement_dir
	
	handle_rotation(delta)
	handle_zoom(delta)
	
	var direction = (transform.basis * Vector3(move_dir.x, 0, move_dir.y)).normalized()
	var move_speed = lerpf(min_speed, max_speed, (zoom_level-min_zoom)/(max_zoom-min_zoom))
	if direction:
		velocity.x = direction.x * move_speed
		velocity.z = direction.z * move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, move_speed)
		velocity.z = move_toward(velocity.z, 0, move_speed)
	
	global_position += velocity * delta

func get_edge_movement_dir() -> Vector2:

	var move_dir = Vector2.ZERO
	#var viewport_size = get_viewport().size
	#var mouse_pos = get_viewport().get_mouse_position()

	# TODO - MAKE THIS LESS ANNOYING
	#if mouse_pos.x < edge_threshold:
		#move_dir.x -= 1
	#elif mouse_pos.x > viewport_size.x - edge_threshold:
		#move_dir.x += 1
#
	#if mouse_pos.y < edge_threshold:
		#move_dir.y -= 1
	#elif mouse_pos.y > viewport_size.y - edge_threshold:
		#move_dir.y += 1
	
	return move_dir

func handle_rotation(delta):
	var horizontal_rotation = Input.get_axis("rotate_left", "rotate_right")
	if horizontal_rotation != 0:
		rotate_y(horizontal_rotation * rotation_speed * delta)

	var vertical_rotation_input = Input.get_axis("rotate_down", "rotate_up")
	if vertical_rotation_input != 0:
		vertical_pivot.rotation.x = clamp(vertical_pivot.rotation.x - vertical_rotation_input * rotation_speed * delta, min_vertical_angle, max_vertical_angle)

func handle_zoom(delta):
	if Input.is_action_just_released("zoom_in"):
		zoom_level -= zoom_increments
	if Input.is_action_just_released("zoom_out"):
		zoom_level += zoom_increments
	zoom_level = clamp(zoom_level, min_zoom, max_zoom)
	camera_3d.position.z = lerpf(camera_3d.position.z, zoom_level, delta * zoom_speed)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_level -= zoom_increments
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_level += zoom_increments
