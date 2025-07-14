extends Resource
class_name GunStats

@export_group("Display")
@export var name = "gun"
@export var display_name = "gun"

@export_group("Attack")
@export var shots_per_s = 1.0
@export var bullets_spread_angle_deg: int = 0
@export var bullets_per_shot: int = 1

@export_group("Sound")
@export var shoot_sound: String = "shoot.wav"
@export var shoot_sfx_options: SfxOptions = preload("res://globals/sound/default_sfx_options.tres")

@export_group("Effects")
@export var eject_cartridges: bool = true
