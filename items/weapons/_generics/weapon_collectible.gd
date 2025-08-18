extends ConsumableItem
class_name WeaponCollectible

@export var weapon_stats: WeaponStats
@export var bullet_stats: BulletStats

func _enter_tree() -> void:
    if !weapon_stats:
        push_warning("weapon collectible has no weapon_stats defined, falling back to default")
        weapon_stats = load("res://items/weapons/_generics/stats/default_weapon_stats.tres")
    if !bullet_stats:
        push_warning("weapon collectible has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/weapons/_generics/stats/default_bullet_stats.tres")

func _ready() -> void:
    Minimap.track(self, Minimap.ObjectType.WEAPON)

func _exit_tree() -> void:
    Minimap.untrack(self)

func get_weapon_name() -> String:
    var scene_path = get_scene_file_path()
    var parts = scene_path.get_base_dir().split("/")
    return parts[-1]
