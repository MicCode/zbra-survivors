extends Node
class_name GameStatLogs

var player_xp: Array[GameStatLogEntry] = []
var player_level: Array[GameStatLogEntry] = []
var dps: Array[GameStatLogEntry] = []


func add_last_points():
    var last_timestamp = get_last_timestamp()
    _add_last_point_in_array(player_xp, last_timestamp)
    _add_last_point_in_array(player_level, last_timestamp)
    _add_last_point_in_array(dps, last_timestamp)

func get_last_timestamp() -> float:
    return max(
        _get_latest_timestamp_from_array(player_xp),
        _get_latest_timestamp_from_array(player_level),
        _get_latest_timestamp_from_array(dps)
    )

func _add_last_point_in_array(array:Array[GameStatLogEntry], last_timestamp: float):
    var last_entry = array[array.size() - 1]
    if last_entry.timestamp != last_timestamp:
        array.append(GameStatLogEntry.create(floor(last_timestamp), last_entry.value))

func _get_latest_timestamp_from_array(array: Array[GameStatLogEntry]) -> float:
    var latest_timestamp = 0.0
    for e in array:
        if e.timestamp > latest_timestamp:
            latest_timestamp = e.timestamp
    return latest_timestamp

func to_dict() -> Dictionary:
    return {
        "player_xp": player_xp.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "player_level": player_level.map(func(entry: GameStatLogEntry): return entry.to_dict()),
        "dps": dps.map(func(entry: GameStatLogEntry): return entry.to_dict())
    }

static func from_dict(dict: Dictionary) -> GameStatLogs:
    var logs: GameStatLogs = GameStatLogs.new()

    logs.player_xp = _load_array(dict, "player_xp")
    logs.player_level = _load_array(dict, "player_level")
    logs.dps = _load_array(dict, "dps")

    return logs

static func _load_array(dict: Dictionary, key: String) -> Array[GameStatLogEntry]:
    var array: Array[GameStatLogEntry] = []
    for e in dict.get(key, []):
        array.append(GameStatLogEntry.from_dict(e))
    return array
