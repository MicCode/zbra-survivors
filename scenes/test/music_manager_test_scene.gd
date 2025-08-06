extends CanvasLayer

func _ready() -> void:
    SoundPlayer.apply_audio_settings()

func _process(_delta: float) -> void:
    %MuffledProgress.value = MusicManager.to_linear(MusicManager.muffled_player.volume_db)
    %SoftProgress.value = MusicManager.to_linear(MusicManager.soft_player.volume_db)
    %MediumProgress.value = MusicManager.to_linear(MusicManager.medium_player.volume_db)
    %HardProgress.value = MusicManager.to_linear(MusicManager.hard_player.volume_db)

func _on_start_music_button_pressed() -> void:
    MusicManager.play()


func _on_stop_music_button_pressed() -> void:
    MusicManager.stop()


func _on_muffled_button_pressed() -> void:
    MusicManager.change_layer(MusicManager.MusicLayer.MUFFLED)


func _on_soft_button_pressed() -> void:
    MusicManager.change_layer(MusicManager.MusicLayer.SOFT)


func _on_medium_button_2_pressed() -> void:
    MusicManager.change_layer(MusicManager.MusicLayer.MEDIUM)


func _on_hard_button_3_pressed() -> void:
    MusicManager.change_layer(MusicManager.MusicLayer.HARD)


func _on_electro_1_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.ELECTRO_1)


func _on_electro_2_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.ELECTRO_2)


func _on_epic_1_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.EPIC_1)


func _on_epic_2_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.EPIC_2)


func _on_metal_1_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.METAL_1)


func _on_metal_2_pressed() -> void:
    MusicManager.change_music(MusicManager.Music.METAL_2)
