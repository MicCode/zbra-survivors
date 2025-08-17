class_name GameStatLogs

var events: Array[GameEventLogEntry] = []

var player_xp: Array[GameStatLogEntry] = []
var player_level: Array[GameStatLogEntry] = []
var dps: Array[GameStatLogEntry] = []

var enemy_spawn_per_m: Array[GameStatLogEntry] = []
var total_enemy_spawned: Array[GameStatLogEntry] = []
var enemy_kill_per_m: Array[GameStatLogEntry] = []
var total_enemy_killed: Array[GameStatLogEntry] = []


func create_bounding_points():
    var last_timestamp = get_last_timestamp()
    _create_array_bounding_points(player_xp, last_timestamp)
    _create_array_bounding_points(player_level, last_timestamp)
    _create_array_bounding_points(dps, last_timestamp)
    _create_array_bounding_points(enemy_spawn_per_m, last_timestamp)
    _create_array_bounding_points(total_enemy_spawned, last_timestamp)
    _create_array_bounding_points(enemy_kill_per_m, last_timestamp)
    _create_array_bounding_points(total_enemy_killed, last_timestamp)

func get_last_timestamp() -> float:
    return max(
        _get_latest_timestamp_from_array(player_xp),
        _get_latest_timestamp_from_array(player_level),
        _get_latest_timestamp_from_array(dps),
        _get_latest_timestamp_from_array(enemy_spawn_per_m),
        _get_latest_timestamp_from_array(total_enemy_spawned),
        _get_latest_timestamp_from_array(enemy_kill_per_m),
        _get_latest_timestamp_from_array(total_enemy_killed)
    )

func to_dict() -> Dictionary:
    return {
        "events": events.map(func(entry: GameEventLogEntry): return entry.to_dict()),
        "player_xp": player_xp.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "player_level": player_level.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "dps": dps.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "enemy_spawn_per_m": enemy_spawn_per_m.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "total_enemy_spawned": total_enemy_spawned.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "enemy_kill_per_m": enemy_kill_per_m.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "total_enemy_killed": total_enemy_killed.map(func(entry: GameStatLogEntry): return entry.to_dict()),
    }

static func from_dict(dict: Dictionary) -> GameStatLogs:
    var logs: GameStatLogs = GameStatLogs.new()

    logs.events = _load_events_array(dict, "events")
    logs.player_xp = _load_stats_array(dict, "player_xp")
    logs.player_level = _load_stats_array(dict, "player_level")
    logs.dps = _load_stats_array(dict, "dps")
    logs.enemy_spawn_per_m = _load_stats_array(dict, "enemy_spawn_per_m")
    logs.total_enemy_spawned = _load_stats_array(dict, "total_enemy_spawned")
    logs.enemy_kill_per_m = _load_stats_array(dict, "enemy_kill_per_m")
    logs.total_enemy_killed = _load_stats_array(dict, "total_enemy_killed")

    return logs

func _create_array_bounding_points(array: Array[GameStatLogEntry], last_timestamp: float):
    var first_entry = array[0]
    if first_entry.timestamp != 0:
        array.push_front(GameStatLogEntry.create(0, 0.0))
    var last_entry = array[array.size() - 1]
    if last_entry.timestamp != last_timestamp:
        array.append(GameStatLogEntry.create(floor(last_timestamp), last_entry.value))

func _get_latest_timestamp_from_array(array: Array[GameStatLogEntry]) -> float:
    var latest_timestamp = 0.0
    for e in array:
        if e.timestamp > latest_timestamp:
            latest_timestamp = e.timestamp
    return latest_timestamp

static func _load_stats_array(dict: Dictionary, key: String) -> Array[GameStatLogEntry]:
    var array: Array[GameStatLogEntry] = []
    for e in dict.get(key, []):
        array.append(GameStatLogEntry.from_dict(e))
    return array

static func _load_events_array(dict: Dictionary, key: String) -> Array[GameEventLogEntry]:
    var array: Array[GameEventLogEntry] = []
    for e in dict.get(key, []):
        array.append(GameEventLogEntry.from_dict(e))
    return array