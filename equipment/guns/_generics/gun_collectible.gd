extends CollectibleItem
class_name GunCollectible

@export var gun_stats: GunStats
@export var bullet_stats: BulletStats

func _enter_tree() -> void:
    if !gun_stats:
        push_warning("gun collectible has no gun_stats defined, falling back to default")
        gun_stats = load("res://equipment/guns/_generics/stats/default_gun_stats.tres")
    if !bullet_stats:
        push_warning("gun collectible has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://equipment/guns/_generics/stats/default_bullet_stats.tres")

func _ready() -> void:
    %GunInfoPanel.init(gun_stats, bullet_stats)
    var joypads = Input.get_connected_joypads()
    if joypads.size() > 0:
        %ButtonIcon.key_name = "A"
        %ButtonIcon.controller_name = "xbox"
    else:
        %ButtonIcon.key_name = "E"
        %ButtonIcon.controller_name = "keyboard"
    %ButtonIcon.update_texture()

func _on_info_display_zone_body_entered(_body: Node2D) -> void:
    if %GunInfoPanel:
        %GunInfoPanel.show()
        %ButtonIcon.show()

func _on_info_display_zone_body_exited(_body: Node2D) -> void:
    if has_node("GunInfoPanel"):
        get_node("GunInfoPanel").hide()
    if has_node("ButtonIcon"):
        get_node("ButtonIcon").hide()
