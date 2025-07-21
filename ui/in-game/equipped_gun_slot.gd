extends PanelContainer

func _ready() -> void:
    GameService.equipped_gun_changed.connect(_update_slot)
    if GameService.equipped_gun:
        _update_slot(GameService.equipped_gun)
    else:
        _update_slot(null)

func _update_slot(new_gun: Gun):
    # print("New gun : " + str(new_gun))
    if new_gun == null:
        %GunSprite.texture = null
        %ShootButton.hide()
        return

    var gun_sprite = new_gun.get_node("PivotPoint/Sprite") as AnimatedSprite2D
    if !gun_sprite:
        push_error("Gun [%s] has no [Sprite] node, unable to load its texture" % str(new_gun))
        return
    if !gun_sprite.sprite_frames:
        push_error("Gun [%s] Sprite has no SpriteFrames defined" % str(new_gun))
        return
    var idle_texture = gun_sprite.sprite_frames.get_frame_texture("idle", 0)
    if !idle_texture:
        push_error("Gun [%s] has no texture defined as first frame of its [idle] animation" % str(new_gun))
        return

    %GunSprite.texture = idle_texture
    %ShootButton.show()
