extends Node

@onready var pause_screen = $CanvasLayer/PauseScreen
@onready var main_menu_button = $CanvasLayer/PauseScreen/Background/MainMenuButton
var last_focus = null
@onready var last_mouse_state = Input.mouse_mode

var paused = false:
	set(value):
		paused = value
		_update_pause_state(value)

func _ready():
	UiSfxManager.add_button(main_menu_button)
	_update_pause_state(paused)

func _process(_delta):
	if Input.is_action_just_pressed("pause") and not get_tree().current_scene.is_in_group("menu"):
		paused = !paused
		

func _update_pause_state(pause_state: bool) -> void:
	if !pause_screen:
		return
	get_tree().paused = pause_state
	pause_screen.visible = pause_state
	
	if(pause_state == true):
		last_focus = get_viewport().gui_get_focus_owner()
		main_menu_button.grab_focus()
		last_mouse_state = Input.mouse_mode
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		if(last_focus != null):
			last_focus.grab_focus()
		if(last_mouse_state != null):
			Input.mouse_mode = last_mouse_state
	
	
func _on_main_menu_button_pressed():
	paused = !paused
	SceneManager.change_to_menu()
	
