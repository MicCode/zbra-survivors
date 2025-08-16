extends Node
signal stats_changed(new_stats: EnemySpawnStats)
signal enemy_died(enemy: Enemy)
signal enemy_spawned(enemy: Enemy)

const ENEMIES_PATH = "res://enemies/"
const SPAWN_DISTANCE_MIN: float = 600.0
const SPAWN_DISTANCE_MAX: float = 700.0

# TODO refactor this to get enemies list from the enemies folder
var spawnable_enemies = [
    "mob_1",
    "mob_2",
    "slime",
]

var all_enemies = [
    "dummy",
] + spawnable_enemies

var stats: EnemySpawnStats = EnemySpawnStats.new()
var spawn_enemies = true
var is_boss_spawned = false
var mob_spawn_timer = Timer.new()
var time_before_boss = Timer.new()
var ui_refresh_timer = Timer.new()

var spawn_timestamps: Array[float] = []
var kill_timestamps: Array[float] = []

func reset():
    is_boss_spawned = false
    stats = EnemySpawnStats.new()
    spawn_timestamps = []
    kill_timestamps = []
    GameService.remaining_time_changed.emit(stats.boss_spawn_time)

func _ready() -> void:
    randomize()
    mob_spawn_timer.one_shot = true
    mob_spawn_timer.timeout.connect(func(): spawn_enemy())
    add_child(mob_spawn_timer)

    time_before_boss.one_shot = true
    time_before_boss.timeout.connect(func(): call_deferred("spawn_boss"))
    add_child(time_before_boss)

    ui_refresh_timer.one_shot = false
    ui_refresh_timer.timeout.connect(func():
        if GameService.game_ui_instance:
            GameService.game_ui_instance.set_remaining_time(time_before_boss.time_left)
    )
    add_child(ui_refresh_timer)

    GameService.remaining_time_changed.emit(stats.boss_spawn_time)
    GameService.boss_changed.connect(on_boss_changed)

func start_spawning():
    mob_spawn_timer.start(stats.spawn_time)
    time_before_boss.start(stats.boss_spawn_time)
    ui_refresh_timer.start(1.0)

func stop_spawning():
    mob_spawn_timer.stop()
    time_before_boss.stop()
    ui_refresh_timer.stop()

func spawn_enemy():
    if !spawn_enemies:
        mob_spawn_timer.start(stats.spawn_time)
        return

    if !SceneManager.current_scene:
        push_error("Cannot spawn enemy while no current_scene is set in SceneManager")
        return

    if !PlayerService.player_instance:
        push_error("Cannot spawn enemy while no player instance is set in GameService")
        return

    var new_enemy: Enemy = spawn_random()
    new_enemy.stats.is_elite = randf() < stats.elite_spawn_chance
    new_enemy.global_position = get_random_point(PlayerService.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
    new_enemy.y_sort_enabled = true
    SceneManager.current_scene.add_child(new_enemy)
    mob_spawn_timer.start(stats.spawn_time)
    increment_total_spawned(1)
    spawn_timestamps.append(Time.get_ticks_msec())
    enemy_spawned.emit(new_enemy)

func spawn_boss(force_position = false, forced_position: Vector2 = Vector2(0, 0)):
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://enemies/boss_1/boss_1.tscn").instantiate()
        boss.scale = Vector2(2.5, 2.5)
        if !force_position:
            boss.global_position = get_random_point(PlayerService.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
        else:
            boss.global_position = forced_position
        SceneManager.current_scene.add_child(boss)
        MusicManager.set_music(MusicManager.Music.METAL_2)

func increment_total_spawned(count: int = 1):
    stats.total_spawned += count
    stats.spawn_time = calculate_spawn_time()
    stats_changed.emit(stats)

func get_kill_per_minute_average() -> float:
    return get_sliding_average(kill_timestamps)

func get_spawn_per_minute_average() -> float:
    return get_sliding_average(spawn_timestamps)

func get_sliding_average(from_array: Array[float]) -> float:
    if from_array.is_empty():
        return 0.0
    cleanup_timestamps(from_array, 60_000)
    return float(from_array.size()) # TODO is this enough ?

func cleanup_timestamps(from_array: Array[float], older_than_timestamp: float):
    if from_array.is_empty():
        return
    var now = Time.get_ticks_msec()
    while from_array.size() > 0 and now - from_array[0] > older_than_timestamp:
        from_array.pop_front()

## Calculates time between two enemy spawns in function of the game state
## see formula: https://docs.google.com/spreadsheets/d/1dy5hZ8k1o6ASQJi3BNGFULr96txgKhC1LiBq4exjh-w/edit?gid=0#gid=0
func calculate_spawn_time() -> float:
    # TODO extract this in dedicated global class ? enemy spawner ?
    var time_factor: float = clamp(GameService.elapsed_time / GameService.MAX_ELAPSED_TIME, 0.0, 1.0)
    var level_factor: float = clamp(float(PlayerService.player_stats.level) / PlayerService.MAX_PLAYER_LEVEL, 0.0, 1.0)
    var progression: float = (time_factor + level_factor) / 2.0
    var curve: float = pow(1.0 - progression, stats.progression_steepness)
    var spawn_time: float = GameService.MIN_SPAWN_TIME + (stats.initial_spawn_time - GameService.MIN_SPAWN_TIME) * curve

    #print("new spawn time: %.2fs (elapsed time: %.2fs)" % [spawn_time, elapsed_time])

    return spawn_time

func register_enemy_death(enemy: Enemy) -> void:
    GameService.increment_score(1)
    kill_timestamps.append(Time.get_ticks_msec())

    var xp_value = Utils.add_percent(enemy.stats.xp_value, PlayerService.player_stats.luck * 2)
    drop_item(preload("res://player/xp_drop.tscn").instantiate().with_value(xp_value), enemy.global_position)
    Announcer.enemy_died()

    var random_item = LootService.get_random_item()
    if random_item:
        drop_item(random_item, enemy.global_position)

    stats.total_killed += 1
    enemy_died.emit(enemy)

func drop_item(item: Node2D, position: Vector2) -> void:
    item.global_position = position
    SceneManager.current_scene.call_deferred("add_child", item)

func get_random_point(origin: Vector2, r_min: float, r_max: float) -> Vector2:
    var angle: float = randf() * TAU
    var radius: float = lerp(r_min, r_max, randf())
    return origin + Vector2(cos(angle), sin(angle)) * radius

func on_boss_changed(boss_stats: EnemyStats, boss_health: float):
    if boss_stats and boss_health <= 0:
        MusicManager.set_music(GameService.music)

func spawn_random() -> Enemy:
    var random_enemy = spawnable_enemies[randi_range(0, spawnable_enemies.size() - 1)]
    var scene_path = _get_enemy_path(random_enemy) + ".tscn"
    var scene = load(scene_path)
    if !scene:
        push_error("enemy scene [" + scene_path + "] not found")
        return null
    var instance = scene.instantiate() as Enemy
    instance.stats = instance.stats.duplicate(true)
    instance.stats.resource_local_to_scene = true
    return instance

func _get_enemy_path(enemy_name: String) -> String:
    return ENEMIES_PATH + enemy_name + "/" + enemy_name
