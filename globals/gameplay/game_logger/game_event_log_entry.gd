class_name GameEventLogEntry

var timestamp: int
var type: E.EventLogType
var value: String

static func create(_timestamp: int, _type: E.EventLogType, _value: String) -> GameEventLogEntry:
    var entry = GameEventLogEntry.new()
    entry.timestamp = _timestamp
    entry.type = _type
    entry.value = _value
    return entry

func to_dict() -> Dictionary:
    return {
        "timestamp": timestamp,
        "type": E.to_str(E.EventLogType, type),
        "value": value
    }

static func from_dict(dict: Dictionary) -> GameEventLogEntry:
    var _timestamp: int = dict.get("timestamp", 0.0)
    var _type: E.EventLogType = E.from_str(E.EventLogType, dict.get("type", "")) as E.EventLogType
    var _value: String = dict.get("value", "")
    return GameEventLogEntry.create(_timestamp, _type, _value)
