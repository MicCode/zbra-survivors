extends PanelContainer

@export var show_control: bool = true
@export var gun: Gun

func change_gun(new_gun: Gun):
    gun = new_gun
    _update_slot(gun)

func _update_slot(new_gun: Gun):
    # print("New gun : " + str(new_gun))
    if new_gun == null:
        %GunSprite.texture = null
        %ButtonIcon.hide()
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
    if show_control:
        %ButtonIcon.show()
    else:
        %ButtonIcon.hide()

    if new_gun.bullet_stats.is_explosive:
        %IsExplosive.show()
    else:
        %IsExplosive.hide()
    if new_gun.bullet_stats.inflicts_fire:
        %IsFire.show()
    else:
        %IsFire.hide()
