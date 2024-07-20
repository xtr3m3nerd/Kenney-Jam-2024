class_name MainMenu
extends Control

@onready var quit_button = $MarginContainer/VBoxContainer/ActionButtons/QuitButton
@onready var play_game_button = $MarginContainer/VBoxContainer/GameButtons/PlayGameButton
@onready var select_level_button = $MarginContainer/VBoxContainer/GameButtons/SelectLevelButton
@onready var how_to_play_button = $MarginContainer/VBoxContainer/GameButtons/HowToPlayButton
@onready var options_button = $MarginContainer/VBoxContainer/GameButtons/OptionsButton
@onready var credits_button = $MarginContainer/VBoxContainer/ActionButtons/CreditsButton

@onready var menu: Menu = get_parent() as Menu

func _ready():
	var buttons: Array[BaseButton] = [quit_button, play_game_button, 
	select_level_button, how_to_play_button, options_button, credits_button]
	UiSfxManager.add_buttons(buttons)
	play_game_button.grab_focus()
	if OS.get_name() == "Web":
		quit_button.hide()

func _process(_delta):
	if Input.is_action_just_pressed("quit"):
		quit()

func _on_play_game_button_pressed():
	SceneManager.play_game_with_level(0)

func _on_quit_button_pressed():
	quit()

func quit():
	if OS.get_name() == "Web":
		return
	get_tree().quit()

func _on_select_level_button_pressed():
	menu.change_to_level_select()

func _on_how_to_play_button_pressed():
	menu.change_to_how_to_play()

func _on_options_button_pressed():
	menu.change_to_options()

func _on_credits_button_pressed():
	menu.change_to_credits()


func _on_continue_button_pressed():
	pass # Replace with function body.


func _on_new_game_button_pressed():
	pass # Replace with function body.


func _on_settings_pressed():
	pass # Replace with function body.
