extends Node2D

var marker_type: Minimap.ObjectType

func _ready() -> void:
    var target_modulate = modulate
    modulate = Color.TRANSPARENT
    get_tree().create_tween().tween_property(self, "modulate", target_modulate, 0.25)
    set_marker_type(marker_type)

func set_size(size: int):
    %Panel.size = Vector2(size, size)
    var scale_factor_x = size / (%Sprite.texture as Texture2D).get_size().x
    var scale_factor_y = size / (%Sprite.texture as Texture2D).get_size().y
    %Sprite.scale = Vector2(
        max(scale_factor_x, scale_factor_y),
        max(scale_factor_x, scale_factor_y)
    )

func set_marker_type(type: Minimap.ObjectType):
    marker_type = type
    match marker_type:
        Minimap.ObjectType.PLAYER:
            modulate = Color.SKY_BLUE
            z_index = 1
            set_size(15)
        Minimap.ObjectType.COLLECTIBLE:
            modulate = Color.DARK_SALMON
            set_size(14)
        Minimap.ObjectType.GUN:
            modulate = Color.LAWN_GREEN
            set_size(16)
        Minimap.ObjectType.ENNEMY:
            modulate = Color.RED
            set_size(6)
        Minimap.ObjectType.BOSS:
            modulate = Color.RED
            set_size(16)
        Minimap.ObjectType.XP:
            modulate = Color.GOLD
            set_size(5)
        Minimap.ObjectType.CHEST:
            modulate = Color.GOLD
            set_size(32)

func set_texture(texture: Texture = null):
    if texture:
        %Sprite.texture = texture
        %Panel.hide()
        %Sprite.show()
    else:
        %Panel.show()
        %Sprite.hide()
