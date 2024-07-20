extends VBoxContainer

const PATH := "user://options.ini"
var config_file: ConfigFile

func _ready():
	load_configuration()
	UiSfxManager.add_sliders([%MusicSlider, %SfxSlider])

func load_configuration():
	config_file = ConfigFile.new()
	if config_file.load(PATH) == OK:
		var music_value = config_file.get_value("audio", "music", 0.5)
		if music_value is float and music_value >= 0.0 and music_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(music_value))
			%MusicSlider.value = music_value
		var sfx_value = config_file.get_value("audio", "sfx", 1.0)
		if sfx_value is float and sfx_value >= 0.0 and sfx_value <= 1.0:
			AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(sfx_value))
			%SfxSlider.value = sfx_value

func _on_music_slider_value_changed(value: float) -> void:
	config_file.set_value("audio", "music", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_sfx_slider_value_changed(value: float) -> void:
	config_file.set_value("audio", "sfx", value)
	config_file.save(PATH)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Sfx"), linear_to_db(value))
