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
## Path to the sound file to play on shoot, can also be a folder path (without extension) if `is_sound_folder` option is set
@export var shoot_sound: String = "shoot.wav"
## Wether the value provided in `shoot_sound` is pointing to a folder name, and thus we will need to load randomly one of the sound in this folder each time
@export var is_sound_folder: bool = false
@export var shoot_sfx_options: SfxOptions = preload("res://globals/sound/default_sfx_options.tres")

@export_group("Effects")
@export var eject_cartridges: bool = true
