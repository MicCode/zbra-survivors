extends Node
class_name PlayerState

# === HEALTH ===
var is_alive = true
var max_health: int = 5
var health: int = 5

# === MOVEMENTS ===
var move_speed: float = 300.0

# === DAMAGES ===
var damage_cooldown_s: float = 1.0

# === DASH ===
var dash_duration_s: float = 0.25
var dash_cooldown_s: float = 3.0
var dash_speed_multiplier: float = 5
var is_dashing = false
var can_dash = true
var dash_gauge_value: int = 5 # [0..5] where 0 = empty and 5 = full