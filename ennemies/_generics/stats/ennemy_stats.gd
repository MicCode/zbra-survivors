extends Resource
class_name EnnemyStats

@export_group("Display")
@export var name = "ennemy"
@export var nice_name = "ennemy nice name"

@export_group("Attributes")
@export var max_health: int = 30
@export var xp_value: float = 1.0
@export var can_die: bool = true

@export_group("Behavior")
@export var speed: float = 200.0
@export var chase_player: bool = true
