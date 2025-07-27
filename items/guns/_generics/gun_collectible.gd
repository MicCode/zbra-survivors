extends ConsumableItem
class_name GunCollectible

@export var gun_stats: GunStats
@export var bullet_stats: BulletStats

func _enter_tree() -> void:
    if !gun_stats:
        push_warning("gun collectible has no gun_stats defined, falling back to default")
        gun_stats = load("res://items/guns/_generics/stats/default_gun_stats.tres")
    if !bullet_stats:
        push_warning("gun collectible has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://items/guns/_generics/stats/default_bullet_stats.tres")

func _ready() -> void:
    Minimap.track(self, Minimap.ObjectType.GUN)
    %GunInfoPanel.init(gun_stats, bullet_stats)

func _on_area_2d_body_entered(_body: Node2D) -> void:
    if %GunInfoPanel:
        %GunInfoPanel.show()
    super._on_area_2d_body_entered(_body)

func _on_area_2d_body_exited(_body: Node2D) -> void:
    if has_node("GunInfoPanel"):
        get_node("GunInfoPanel").hide()
    super._on_area_2d_body_exited(_body)

func _exit_tree() -> void:
    Minimap.untrack(self)
