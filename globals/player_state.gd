extends Node
class_name PlayerState

# === HEALTH ===
var is_alive = true
var max_health: int = 5
var health: int = 5

# === XP ===
var xp: float = 0.0
var xp_collect_radius: float = 50.0
var level: int = 1
var next_level_xp: float = 10.0

# === MOVEMENTS ===
var move_speed: float = 200.0

# === DAMAGES ===
var damage_cooldown_s: float = 1.0

# === DASH ===
var dash_duration_s: float = 0.25
var dash_cooldown_s: float = 3.0
var dash_speed_multiplier: float = 3
var is_dashing = false
var can_dash = true
var dash_gauge_value: int = 5 # [0..5] where 0 = empty and 5 = full

# === DROP CHANCES ===
var life_drop_chance: float = 0.1
var radiance_drop_chance: float = 0.1
var timewrap_drop_change: float = 0.1
var xp_collector_drop_chance: float = 0.1
var land_mine_chance: float = 0.1
