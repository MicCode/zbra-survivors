extends Node
class_name PlayerState

# === HEALTH ===
var is_alive = true
var max_health: int = 5
var health: int = 5

# === XP ===
var xp: float = 0.0
var xp_collect_radius: float = 100.0
var level: int = 1
var next_level_xp: float = 10.0

# === MOVEMENTS ===
var move_speed: float = 200.0

# === DAMAGES ===
var damage_cooldown_s: float = 1.0

# === DASH ===
var dash_duration_s: float = 0.25
var dash_cooldown_s: float = 3.0
var dash_speed_multiplier: float = 5
var is_dashing = false
var can_dash = true
var dash_gauge_value: int = 5 # [0..5] where 0 = empty and 5 = full

## Reset all player statistics, like if the game has just been started
func reset():
	is_alive = true
	max_health = 5
	health = 5
	xp = 0.0
	xp_collect_radius = 100.0
	level = 1
	next_level_xp = 10.0
	move_speed = 300.0
	damage_cooldown_s = 1.0
	dash_duration_s = 0.25
	dash_cooldown_s = 3.0
	dash_speed_multiplier = 5
	is_dashing = false
	can_dash = true
	dash_gauge_value = 5
