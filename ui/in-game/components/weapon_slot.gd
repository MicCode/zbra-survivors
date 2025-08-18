extends PanelContainer
class_name WeaponSlotUI

@export var show_control: bool = true
@export var weapon: Weapon

func change_weapon(new_weapon: Weapon):
    weapon = new_weapon
    _update_slot(weapon)

func _update_slot(new_weapon: Weapon):
    # print("New weapon : " + str(new_weapon))
    if new_weapon == null:
        %WeaponSprite.texture = null
        %ButtonIcon.hide()
        %IsExplosive.hide()
        %IsFire.hide()
        return

    var new_weapon_sprite = new_weapon.get_node("PivotPoint/Sprite") as AnimatedSprite2D
    if !new_weapon_sprite:
        push_error("Weapon [%s] has no [Sprite] node, unable to load its texture" % str(new_weapon))
        return
    if !new_weapon_sprite.sprite_frames:
        push_error("Weapon [%s] Sprite has no SpriteFrames defined" % str(new_weapon))
        return
    var idle_texture = new_weapon_sprite.sprite_frames.get_frame_texture("idle", 0)
    if !idle_texture:
        push_error("Weapon [%s] has no texture defined as first frame of its [idle] animation" % str(new_weapon))
        return

    %WeaponSprite.texture = idle_texture
    if show_control:
        %ButtonIcon.show()
    else:
        %ButtonIcon.hide()

    if new_weapon.bullet_stats.is_explosive:
        %IsExplosive.show()
    else:
        %IsExplosive.hide()
    if new_weapon.bullet_stats.inflicts_fire:
        %IsFire.show()
    else:
        %IsFire.hide()
