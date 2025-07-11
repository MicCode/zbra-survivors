extends Resource
class_name EnnemyStats

@export var name = "ennemy"
@export var nice_name = "ennemy nice name"
@export var max_health: int = 30
@export var health: int = 30
@export var speed: float = 200.0
@export var xp_value: float = 1.0
@export var can_die: bool = true

func with_name(_name: String) -> EnnemyStats:
    name = _name
    return self

func with_nice_name(_nice_name: String) -> EnnemyStats:
    nice_name = _nice_name
    return self

func with_max_health(_max_health: int) -> EnnemyStats:
    max_health = _max_health
    health = _max_health
    return self

func with_speed(_speed: float) -> EnnemyStats:
    speed = _speed
    return self

func with_xp_value(_xp_value: float) -> EnnemyStats:
    xp_value = _xp_value
    return self

func with_can_die(_can_die: bool) -> EnnemyStats:
    can_die = _can_die
    return self
