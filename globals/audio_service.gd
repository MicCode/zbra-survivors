extends Node

const SOUNDS_DIRECTORY = "res://sounds/"
const MUSICS_DIRECTORY = "res://sounds/music/"

func play_oneshot(sound_name: String) -> void:
	var sound = _load_sound(sound_name, SOUNDS_DIRECTORY)
	if sound:
		var sound_player = AudioStreamPlayer.new()
		sound_player.stream = sound
		add_child(sound_player)
		sound_player.process_mode = Node.PROCESS_MODE_ALWAYS
		sound_player.play()
		sound_player.finished.connect(func():
			sound_player.queue_free()
		)
	

func _load_sound(sound_name: String, directory: String) -> Resource:
	if ResourceLoader.exists(directory + sound_name + ".mp3"):
		return load(directory + sound_name + ".mp3")
	elif ResourceLoader.exists(directory + sound_name + ".wav"):
		return load(directory + sound_name + ".wav")
	elif ResourceLoader.exists(directory + sound_name + ".ogg"):
		return load(directory + sound_name + ".ogg")
	else:
		print_debug("Cannot find sound [" + sound_name + "] in " + directory)
		return null
