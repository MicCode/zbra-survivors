extends Node2D

const PLAY_MUSIC = true
var is_boss_spawned = false

func spawn_boss():
    if !is_boss_spawned:
        is_boss_spawned = true
        %BossSpawnTrigger.modulate = Color(1, 1, 1, 0.25)

        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        add_child(boss)
        boss.global_position = %BossSpawnPoint.global_position
        if PLAY_MUSIC:
            SoundPlayer.play_music("boss.mp3")

func _on_boss_spawn_trigger_body_entered(_body: Node2D) -> void:
    call_deferred("spawn_boss")
