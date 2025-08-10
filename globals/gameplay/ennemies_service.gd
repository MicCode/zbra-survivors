extends Node
const ENNEMIES_PATH = "res://ennemies/"
const SPAWN_DISTANCE_MIN: float = 600.0
const SPAWN_DISTANCE_MAX: float = 700.0

var spawnable_ennemies = [
    "mob_1",
    "mob_2",
    "slime",
]

var all_ennemies = [
    "dummy",
] + spawnable_ennemies

var spawn_ennemies = true
var is_boss_spawned = false

var mob_spawn_timer = Timer.new()
var time_before_boss = Timer.new()
var ui_refresh_timer = Timer.new()

func reset():
    is_boss_spawned = false
    GameState.remaining_time_changed.emit(GameState.ennemy_spawn_stats.boss_spawn_time)

func _ready() -> void:
    randomize()
    mob_spawn_timer.one_shot = true
    mob_spawn_timer.timeout.connect(func(): spawn_ennemy())
    add_child(mob_spawn_timer)

    time_before_boss.one_shot = true
    time_before_boss.timeout.connect(func(): call_deferred("spawn_boss"))
    add_child(time_before_boss)

    ui_refresh_timer.one_shot = false
    ui_refresh_timer.timeout.connect(func():
        if GameState.game_ui_instance:
            GameState.game_ui_instance.set_remaining_time(time_before_boss.time_left)
    )
    add_child(ui_refresh_timer)

    GameState.remaining_time_changed.emit(GameState.ennemy_spawn_stats.boss_spawn_time)
    GameState.boss_changed.connect(on_boss_changed)

func start_spawning():
    mob_spawn_timer.start(GameState.ennemy_spawn_stats.spawn_time)
    time_before_boss.start(GameState.ennemy_spawn_stats.boss_spawn_time)
    ui_refresh_timer.start(1.0)

func stop_spawning():
    mob_spawn_timer.stop()
    time_before_boss.stop()
    ui_refresh_timer.stop()

func spawn_ennemy():
    if !spawn_ennemies:
        mob_spawn_timer.start(GameState.ennemy_spawn_stats.spawn_time)
        return

    if !SceneManager.current_scene:
        push_error("Cannot spawn ennemy while no current_scene is set in SceneManager")
        return

    if !GameState.player_instance:
        push_error("Cannot spawn ennemy while no player instance is set in GameState")
        return

    var new_ennemy = spawn_random()
    if randf() < GameState.ennemy_spawn_stats.elite_spawn_chance:
        new_ennemy.stats.is_elite = true

    new_ennemy.global_position = get_random_point(GameState.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
    new_ennemy.y_sort_enabled = true
    SceneManager.current_scene.add_child(new_ennemy)
    mob_spawn_timer.start(GameState.ennemy_spawn_stats.spawn_time)
    GameState.increment_total_spawned(1)

func spawn_boss():
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        boss.scale = Vector2(2.5, 2.5)
        boss.global_position = get_random_point(GameState.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
        SceneManager.current_scene.add_child(boss)
        MusicManager.set_music(MusicManager.Music.METAL_2)

func get_random_point(origin: Vector2, r_min: float, r_max: float) -> Vector2:
    var angle: float = randf() * TAU
    var radius: float = lerp(r_min, r_max, randf())
    return origin + Vector2(cos(angle), sin(angle)) * radius

func on_boss_changed(boss_stats: EnnemyStats, boss_health: float):
    if boss_stats and boss_health <= 0:
        MusicManager.set_music(MusicManager.Music.METAL_1)

func spawn_random() -> Ennemy:
    var random_ennemy = spawnable_ennemies[randi_range(0, spawnable_ennemies.size() - 1)]
    var scene_path = _get_ennemy_path(random_ennemy) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("ennemy scene [" + scene_path + "] not found")
        return null
    var instance = scene.instantiate() as Ennemy
    instance.stats.resource_local_to_scene = true
    return instance

func _get_ennemy_path(ennemy_name: String) -> String:
    return ENNEMIES_PATH + ennemy_name + "/" + ennemy_name
