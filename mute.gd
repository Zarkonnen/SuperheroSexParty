extends AudioStreamPlayer2D

var mute = false

func _process(delta):
	if Input.is_action_just_released("mute"):
		mute = !mute
		if mute:
			%MusicPlayer.volume_db = -100
		else:
			%MusicPlayer.volume_db = 0
