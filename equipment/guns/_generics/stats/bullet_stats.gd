extends Resource
class_name BulletStats

@export_group("Attributes")
@export_subgroup("Damages")
@export var damage: int = 10

@export_subgroup("Movement")
@export var speed: float = 200
@export var speed_variation: float = 0.0
@export var disapear_delay: float = 0.0
@export var fly_range = 2000.0

@export_subgroup("Size")
@export var size: float = 1.0
@export var size_variation: float = 0.0

@export_group("Effects")
@export var pierce_count: int = 0
@export var inflicts_fire: bool = false
