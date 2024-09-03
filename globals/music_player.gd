extends AudioStreamPlayer

var current_clip_name: String

func _ready() -> void:
	current_clip_name = "MainTheme"

func switch_to(clip_name: String):
	if clip_name != current_clip_name:
		current_clip_name = clip_name
		get_stream_playback().switch_to_clip_by_name(clip_name)

func _on_finished() -> void:
	if current_clip_name != null:
		# FIXME this code to restart current music on finish is not working
		get_stream_playback().switch_to_clip_by_name(current_clip_name)
		play()
