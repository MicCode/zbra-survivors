extends Node

# TODO log player health
# TODO log player max health

# TODO log spawned enemies types & stats ?
# TODO log enemies spawn time

# TODO log modifiers acquisition
# TODO log items acquisitions
# TODO log gun swap
# TODO log items uses

const LOGS_SAVE_DIR: String = "user://game_logs"

var is_logging = false
var start_timestamp: float = 0.0
var logs: GameStatLogs = GameStatLogs.new()
var logs_filename: String = "not-set.json"

@onready var s_timer: Timer = Timer.new()

func _ready() -> void:
    s_timer.wait_time = 1.0
    s_timer.autostart = true
    s_timer.one_shot = false
    add_child(s_timer)
    s_timer.timeout.connect(on_s_timer_timeout)

#region controls
func start_logging():
    if is_logging:
        stop_logging()

    is_logging = true
    logs = GameStatLogs.new()
    start_timestamp = Time.get_unix_time_from_system()
    logs_filename = get_new_filename()


    _log(logs.player_level, 0)
    PlayerService.player_gained_level.connect(log_player_level)
    _log(logs.player_xp, 0)
    PlayerService.player_gained_xp.connect(log_player_xp)
    _log(logs.dps, 0)
    GunService.gun_stats_changed.connect(log_gun_stats)

    _log(logs.enemy_kill_per_m, 0)
    _log(logs.total_enemy_killed, 0)
    _log(logs.enemy_spawn_per_m, 0)
    _log(logs.total_enemy_spawned, 0)

func on_s_timer_timeout():
    if is_logging:
        log_enemy_death()
        log_enemy_spawn()

func stop_logging():
    is_logging = false
    PlayerService.player_gained_level.disconnect(log_player_level)
    PlayerService.player_gained_xp.disconnect(log_player_xp)
    GunService.gun_stats_changed.disconnect(log_gun_stats)
    save_to_file()

#endregion

#region loggers
func log_player_level(_n: int):
    _log(logs.player_level, PlayerService.player_stats.level)

func log_player_xp(_n: int):
    _log(logs.player_xp, PlayerService.player_stats.total_xp)

func log_gun_stats(_gun_stats: GunStats):
    if GunService.equipped_gun:
        _log(logs.dps, Conversions.dps(GunService.equipped_gun.gun_stats, GunService.equipped_gun.bullet_stats))

func log_enemy_death():
    _log(logs.enemy_kill_per_m, EnemiesService.get_kill_per_minute_average())
    _log(logs.total_enemy_killed, EnemiesService.stats.total_killed)

func log_enemy_spawn():
    _log(logs.enemy_spawn_per_m, EnemiesService.get_spawn_per_minute_average())
    _log(logs.total_enemy_spawned, EnemiesService.stats.total_spawned)
#endregion

#region utils
func _log(array: Array[GameStatLogEntry], value: float):
    array.append(GameStatLogEntry.create(timestamp(), value))
    save_to_file()

func timestamp() -> int:
    return ceil((Time.get_unix_time_from_system() - start_timestamp) * 1000)

func save_to_file():
    # TODO add a csv export tool
    if !logs_filename == "not-set.json":
        Files.write_file(LOGS_SAVE_DIR.path_join(logs_filename), logs.to_dict())

func load_from_latest_file() -> GameStatLogs:
    var existing_log_files = DirAccess.get_files_at(LOGS_SAVE_DIR)
    existing_log_files.sort()
    var latest_file_path = LOGS_SAVE_DIR.path_join(existing_log_files[existing_log_files.size() - 1])
    print(str("Loading logs from [%s]" % latest_file_path))
    var dict: Dictionary = Files.read_file(latest_file_path)
    return GameStatLogs.from_dict(dict)

func get_new_filename() -> String:
    if not DirAccess.dir_exists_absolute(LOGS_SAVE_DIR):
        DirAccess.make_dir_absolute(LOGS_SAVE_DIR)
    var existing_log_files = DirAccess.get_files_at(LOGS_SAVE_DIR)
    return str("game-log-%s.json" % str(existing_log_files.size() + 1).pad_zeros(5))

#endregion
