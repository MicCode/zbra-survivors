extends AudioStreamPlayer

var current_clip_name: String

func _ready() -> void:
	current_clip_name = "MainTheme"

func switch_to(clip_name: String):
	if playing && clip_name != current_clip_name:
		current_clip_name = clip_name
		get_stream_playback().switch_to_clip_by_name(clip_name)
