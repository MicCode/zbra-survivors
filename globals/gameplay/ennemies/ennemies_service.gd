extends Node
signal ennemy_spawn_stats_changed(new_stats: EnnemySpawnStats)

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

var ennemy_spawn_stats: EnnemySpawnStats = EnnemySpawnStats.new()

var spawn_ennemies = true
var is_boss_spawned = false

var mob_spawn_timer = Timer.new()
var time_before_boss = Timer.new()
var ui_refresh_timer = Timer.new()

func reset():
    is_boss_spawned = false
    ennemy_spawn_stats = EnnemySpawnStats.new()
    GameService.remaining_time_changed.emit(ennemy_spawn_stats.boss_spawn_time)

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
        if GameService.game_ui_instance:
            GameService.game_ui_instance.set_remaining_time(time_before_boss.time_left)
    )
    add_child(ui_refresh_timer)

    GameService.remaining_time_changed.emit(ennemy_spawn_stats.boss_spawn_time)
    GameService.boss_changed.connect(on_boss_changed)

func start_spawning():
    mob_spawn_timer.start(ennemy_spawn_stats.spawn_time)
    time_before_boss.start(ennemy_spawn_stats.boss_spawn_time)
    ui_refresh_timer.start(1.0)

func stop_spawning():
    mob_spawn_timer.stop()
    time_before_boss.stop()
    ui_refresh_timer.stop()

func spawn_ennemy():
    if !spawn_ennemies:
        mob_spawn_timer.start(ennemy_spawn_stats.spawn_time)
        return

    if !SceneManager.current_scene:
        push_error("Cannot spawn ennemy while no current_scene is set in SceneManager")
        return

    if !PlayerService.player_instance:
        push_error("Cannot spawn ennemy while no player instance is set in GameService")
        return

    var new_ennemy = spawn_random()
    new_ennemy.stats.is_elite = randf() < ennemy_spawn_stats.elite_spawn_chance

    new_ennemy.global_position = get_random_point(PlayerService.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
    new_ennemy.y_sort_enabled = true
    SceneManager.current_scene.add_child(new_ennemy)
    mob_spawn_timer.start(ennemy_spawn_stats.spawn_time)
    increment_total_spawned(1)

func spawn_boss(force_position = false, forced_position: Vector2 = Vector2(0, 0)):
    if !is_boss_spawned:
        is_boss_spawned = true
        var boss = preload("res://ennemies/boss_1/boss_1.tscn").instantiate()
        boss.scale = Vector2(2.5, 2.5)
        if !force_position:
            boss.global_position = get_random_point(PlayerService.player_instance.global_position, SPAWN_DISTANCE_MIN, SPAWN_DISTANCE_MAX)
        else:
            boss.global_position = forced_position
        SceneManager.current_scene.add_child(boss)
        MusicManager.set_music(MusicManager.Music.METAL_2)

func increment_total_spawned(count: int = 1):
    ennemy_spawn_stats.total_spawned += count
    ennemy_spawn_stats.spawn_time = calculate_spawn_time()
    ennemy_spawn_stats_changed.emit(ennemy_spawn_stats)

## Calculates time between two ennemy spawns in function of the game state
## see formula: https://docs.google.com/spreadsheets/d/1dy5hZ8k1o6ASQJi3BNGFULr96txgKhC1LiBq4exjh-w/edit?gid=0#gid=0
func calculate_spawn_time() -> float:
    # TODO extract this in dedicated global class ? ennemy spawner ?
    var time_factor: float = clamp(GameService.elapsed_time / GameService.MAX_ELAPSED_TIME, 0.0, 1.0)
    var level_factor: float = clamp(float(PlayerService.player_stats.level) / PlayerService.MAX_PLAYER_LEVEL, 0.0, 1.0)
    var progression: float = (time_factor + level_factor) / 2.0
    var curve: float = pow(1.0 - progression, ennemy_spawn_stats.progression_steepness)
    var spawn_time: float = GameService.MIN_SPAWN_TIME + (ennemy_spawn_stats.initial_spawn_time - GameService.MIN_SPAWN_TIME) * curve

    #print("new spawn time: %.2fs (elapsed time: %.2fs)" % [spawn_time, elapsed_time])

    return spawn_time

func register_ennemy_death(ennemy: Ennemy) -> void:
    GameService.increment_score(1)
    drop_item(preload("res://player/xp_drop.tscn").instantiate().with_value(ennemy.stats.xp_value), ennemy.global_position)
    Announcer.ennemy_died()

    var random_item = LootService.get_random_item()
    if random_item:
        drop_item(random_item, ennemy.global_position)

func drop_item(item: Node2D, position: Vector2) -> void:
    item.global_position = position
    SceneManager.current_scene.call_deferred("add_child", item)

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
    instance.stats = instance.stats.duplicate(true)
    instance.stats.resource_local_to_scene = true
    return instance

func _get_ennemy_path(ennemy_name: String) -> String:
    return ENNEMIES_PATH + ennemy_name + "/" + ennemy_name
