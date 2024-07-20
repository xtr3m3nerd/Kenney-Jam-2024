class_name AudioStreamPool
extends Node

@export var template_player: AudioStreamPlayer
@export var pool_size = 5

func _ready():
	for i in pool_size:
		var player = null
		if template_player == null:
			player = AudioStreamPlayer.new()
		else:
			player = template_player.duplicate()
		add_child(player)

func play():
	var player = get_child(-1) as AudioStreamPlayer
	player.play()
	move_child(player, 0)
