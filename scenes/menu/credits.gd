extends Control

@onready var menu: Menu = get_parent() as Menu

@export var credits: Array[String]

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		menu.change_to_main_menu()
	if Input.is_action_just_pressed("main_action"):
		menu.change_to_main_menu()
	if Input.is_action_just_pressed("ui_accept"):
		menu.change_to_main_menu()
