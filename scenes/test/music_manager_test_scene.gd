extends CanvasLayer

func _ready() -> void:
    Settings.apply_audio_settings()

func _process(_delta: float) -> void:
    %MuffledProgress.value = MusicManager.get_player_volume_linear(E.MusicLayer.MUFFLED)
    %SoftProgress.value = MusicManager.get_player_volume_linear(E.MusicLayer.SOFT)
    %MediumProgress.value = MusicManager.get_player_volume_linear(E.MusicLayer.MEDIUM)
    %HardProgress.value = MusicManager.get_player_volume_linear(E.MusicLayer.HARD)

func _on_start_music_button_pressed() -> void:
    MusicManager.play()


func _on_stop_music_button_pressed() -> void:
    MusicManager.stop()


func _on_muffled_button_pressed() -> void:
    MusicManager.set_layer(E.MusicLayer.MUFFLED)


func _on_soft_button_pressed() -> void:
    MusicManager.set_layer(E.MusicLayer.SOFT)


func _on_medium_button_2_pressed() -> void:
    MusicManager.set_layer(E.MusicLayer.MEDIUM)


func _on_hard_button_3_pressed() -> void:
    MusicManager.set_layer(E.MusicLayer.HARD)


func _on_electro_1_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.ELECTRO_1)


func _on_electro_2_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.ELECTRO_2)


func _on_epic_1_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.EPIC_1)


func _on_epic_2_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.EPIC_2)


func _on_metal_1_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.METAL_1)


func _on_metal_2_pressed() -> void:
    MusicManager.set_music(MusicManager.Music.METAL_2)


func _on_non_layered_pressed() -> void:
    MusicManager.set_non_layered_music("mystery.mp3")
