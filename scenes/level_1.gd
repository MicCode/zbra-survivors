extends Node2D

var is_boss_spawned = false
const TIME_BEFORE_BOSS_S: float = 180.0

func _enter_tree() -> void:
    Minimap.clear()

func _ready():
    Engine.time_scale = 1.0
    %TimeBeforeBoss.start(TIME_BEFORE_BOSS_S)
    %GameUI.set_remaining_time(%TimeBeforeBoss.time_left)
    GameState.reset()
    get_tree().paused = false
    Musics.lvl_1()

func _on_remaining_time_interval_timeout() -> void:
    %GameUI.set_remaining_time(%TimeBeforeBoss.time_left)

func _on_time_before_boss_timeout() -> void:
    call_deferred("spawn_boss")

func spawn_boss():
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        boss.scale = Vector2(2.5, 2.5)
        boss.global_position = get_random_point(GameState.player_instance.global_position, 500, 700)
        add_child(boss)
        Musics.boss_battle_1()
        GameState.boss_changed.connect(on_boss_changed)

func get_random_point(origin: Vector2, r_min: float, r_max: float) -> Vector2:
    var angle: float = randf() * TAU
    var radius: float = lerp(r_min, r_max, randf())
    return origin + Vector2(cos(angle), sin(angle)) * radius

func on_boss_changed(_boss_stats: EnnemyStats, boss_health: float):
    if boss_health <= 0:
        Musics.lvl_1()
