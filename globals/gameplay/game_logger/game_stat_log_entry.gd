extends Node
class_name GameStatLogEntry

var timestamp: int
var value: float

static func create(_timestamp: int, _value: float) -> GameStatLogEntry:
    var entry = GameStatLogEntry.new()
    entry.timestamp = _timestamp
    entry.value = _value
    return entry

func to_dict() -> Dictionary:
    return {
        "timestamp": timestamp,
        "value": value
    }

static func from_dict(dict: Dictionary) -> GameStatLogEntry:
    var _timestamp: int = dict.get("timestamp", 0.0)
    var _value: float = dict.get("value", 0.0)
    return GameStatLogEntry.create(_timestamp, _value)
