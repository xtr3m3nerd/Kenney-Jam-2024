extends Node
class_name Menu

@export var main_menu_scene: PackedScene
@export var level_select_scene: PackedScene
@export var how_to_play_scene: PackedScene
@export var credits_scene: PackedScene
@export var options_scene: PackedScene

@onready var canvas_layer = $CanvasLayer
@onready var current_scene = $CanvasLayer/MainMenu

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	current_scene.menu = self
	MusicManager.play_intro_music()

func change_to_main_menu() -> void:
	change_to_scene(main_menu_scene)

func change_to_level_select() -> void:
	change_to_scene(level_select_scene)

func change_to_how_to_play() -> void:
	change_to_scene(how_to_play_scene)
	
func change_to_credits() -> void:
	change_to_scene(credits_scene)

func change_to_options() -> void:
	change_to_scene(options_scene)
	
func change_to_scene(scene: PackedScene) -> void:
	canvas_layer.remove_child(current_scene)
	current_scene.queue_free()
	current_scene = scene.instantiate()
	canvas_layer.add_child(current_scene)
	current_scene.menu = self
