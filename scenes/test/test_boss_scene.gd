extends Node2D

const PLAY_MUSIC = false
var is_boss_spawned = false

func _ready() -> void:
	if PLAY_MUSIC:
		%MusicPlayer.play()

func spawn_boss():
	if !is_boss_spawned:
		is_boss_spawned = true
		AudioService.play_oneshot("hit")
		%BossSpawnTrigger.modulate = Color(1, 1, 1, 0.25)
		
		var boss = preload("res://ennemies/boss_1/Boss1.tscn").instantiate()
		add_child(boss)
		boss.global_position = %BossSpawnPoint.global_position
		%MusicPlayer.switch_to("BossBattle")

func _on_boss_spawn_trigger_body_entered(body: Node2D) -> void:
	call_deferred("spawn_boss")
		
		
