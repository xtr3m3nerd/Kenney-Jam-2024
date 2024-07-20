extends Node

@onready var button_noise_pool = $ButtonNoisePool as AudioStreamPool
@onready var hover_noise_pool = $HoverNoisePool as AudioStreamPool

var debounce: bool = false

func play_button_press() -> void:
	button_noise_pool.play()
	
func play_slider_changed(_value: float) -> void:
	if debounce == false:
		debounce = true
		play_button_hover()

func play_button_hover() -> void:
	hover_noise_pool.play()

func add_button(button: BaseButton) -> void:
	if not button.pressed.is_connected(play_button_press):
		button.pressed.connect(play_button_press)
	if not button.mouse_entered.is_connected(play_button_hover):
		button.mouse_entered.connect(play_button_hover)

func remove_button(button: BaseButton) -> void:
	if button.pressed.is_connected(play_button_press):
		button.pressed.disconnect(play_button_press)
	if button.mouse_entered.is_connected(play_button_hover):
		button.mouse_entered.disconnect(play_button_hover)

func add_buttons(buttons: Array[BaseButton]) -> void:
	for button in buttons:
		add_button(button)
		
func remove_buttons(buttons: Array[BaseButton]) -> void:
	for button in buttons:
		remove_button(button)

func add_slider(slider: Slider) -> void:
	if not slider.value_changed.is_connected(play_slider_changed):
		slider.value_changed.connect(play_slider_changed)
	if not slider.mouse_entered.is_connected(play_button_hover):
		slider.mouse_entered.connect(play_button_hover)

func remove_slider(slider: Slider) -> void:
	if slider.value_changed.is_connected(play_slider_changed):
		slider.value_changed.disconnect(play_slider_changed)
	if slider.mouse_entered.is_connected(play_button_hover):
		slider.mouse_entered.disconnect(play_button_hover)

func add_sliders(sliders: Array[Slider]) -> void:
	for slider in sliders:
		add_slider(slider)

func remove_sliders(sliders: Array[Slider]) -> void:
	for slider in sliders:
		remove_slider(slider)

func _on_button_noises_finished():
	debounce = false
