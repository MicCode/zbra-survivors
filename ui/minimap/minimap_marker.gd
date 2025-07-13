extends Node2D

var marker_type: Minimap.ObjectType

func _ready() -> void:
    var target_modulate = modulate
    modulate = Color.TRANSPARENT
    get_tree().create_tween().tween_property(self, "modulate", target_modulate, 0.25)

func set_size(size: int):
    %Panel.size = Vector2(size, size)

func set_marker_type(type: Minimap.ObjectType):
    marker_type = type
    match marker_type:
        Minimap.ObjectType.PLAYER:
            modulate = Color.SKY_BLUE
            z_index = 1
            set_size(10)
        Minimap.ObjectType.COLLECTIBLE:
            modulate = Color.DARK_SALMON
            set_size(8)
        Minimap.ObjectType.GUN:
            modulate = Color.LAWN_GREEN
            set_size(8)
        Minimap.ObjectType.ENNEMY:
            modulate = Color.RED
            set_size(6)
        Minimap.ObjectType.BOSS:
            modulate = Color.RED
            set_size(12)
        Minimap.ObjectType.XP:
            modulate = Color.GOLD
            set_size(5)
