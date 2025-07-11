class_name EnnemyInfo

var name = "ennemy"
var nice_name = "ennemy nice name"
var max_health: int = 30
var health: int = 30
var speed: float = 200.0
var xp_value: float = 1.0
var can_die: bool = true

func with_name(_name: String) -> EnnemyInfo:
    name = _name
    return self

func with_nice_name(_nice_name: String) -> EnnemyInfo:
    nice_name = _nice_name
    return self

func with_max_health(_max_health: int) -> EnnemyInfo:
    max_health = _max_health
    health = _max_health
    return self

func with_speed(_speed: float) -> EnnemyInfo:
    speed = _speed
    return self

func with_xp_value(_xp_value: float) -> EnnemyInfo:
    xp_value = _xp_value
    return self

func with_can_die(_can_die: bool) -> EnnemyInfo:
    can_die = _can_die
    return self
