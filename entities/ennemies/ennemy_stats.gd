class_name EnnemyStats

var max_health: float = 3.0
var health: float = 3.0
var speed: float = 200.0

static func create(_health: float, _speed: float) -> EnnemyStats:
    var instance = EnnemyStats.new()
    instance.max_health = _health
    instance.health = _health
    instance.speed = _speed
    return instance

