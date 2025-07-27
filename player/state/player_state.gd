extends Resource
class_name PlayerState

@export_group("Health")
@export var is_alive: bool
@export var max_health: int
@export var health: int

@export_group("XP")
@export var xp: float
@export var xp_collect_radius: float
@export var level: int
@export var next_level_xp: float

@export_group("Movements")
@export var move_speed: float
@export var move_speed_factor: float

@export_group("Damages")
@export var damage_cooldown_s: float

@export_group("Dash")
@export var dash_duration_s: float
@export var dash_cooldown_s: float
@export var dash_speed_multiplier: float
@export var is_dashing: bool
@export var can_dash: bool
@export var dash_gauge_value: int

@export_group("Drop chances")
@export var life_drop_chance: float
@export var radiance_drop_chance: float
@export var timewrap_drop_change: float
@export var xp_collector_drop_chance: float
@export var land_mine_chance: float
