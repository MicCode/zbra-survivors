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
	var sound_file = load(directory + sound_name + ".mp3")
	if sound_file == null:
		sound_file = load(directory + sound_name + ".wav")
	if sound_file == null:
		sound_file = load(directory + sound_name + ".ogg")
	if sound_file == null:
		print_debug("Cannot find sound [" + sound_name + "] in " + directory)
	return sound_file
