class_name EnnemyInfo

var name = "ennemy"
var max_health: float = 3.0
var health: float = 3.0
var speed: float = 200.0
var xp_value: float = 1.0

func with_name(_name: String) -> EnnemyInfo:
    name = _name
    return self

func with_max_health(_max_health: float) -> EnnemyInfo:
    max_health = _max_health
    health = _max_health
    return self

func with_speed(_speed: float) -> EnnemyInfo:
    speed = _speed
    return self

func with_xp_value(_xp_value: float) -> EnnemyInfo:
    xp_value = _xp_value
    return self