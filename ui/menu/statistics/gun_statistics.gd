extends PanelContainer

@export var subtitle_label: String = "SUBTITLE_EQUIPPED_GUN"
@export var is_current_gun: bool = true

var gun: Gun

func _ready() -> void:
    refresh_display()
    if is_current_gun:
        change_gun(GameState.equipped_gun)
        GameState.equipped_gun_changed.connect(change_gun)

func change_gun(new_gun: Gun):
    gun = new_gun
    %GunSlot.change_gun(new_gun)
    refresh_display()

func refresh_display():
    if is_current_gun && !gun:
        %Stats.hide()
        %NoGun.show()
        return
    if !is_current_gun && !gun:
        push_error("Tried to display gun statistics without gun defined")
        %Stats.hide()
        return

    %Stats.show()
    %NoGun.hide()

    %SubtitleLabel.text = tr(subtitle_label)
    %GunName.text = tr(gun.gun_stats.display_name)

    %Damage.set_value(gun.bullet_stats.damage)
    %DamagePerS.set_value(gun.get_dps())
    %ShotPerS.set_value(gun.gun_stats.shots_per_s)
    %BulletsPerShot.set_value(gun.gun_stats.bullets_per_shot)
    %SpreadAngle.set_value(gun.gun_stats.bullets_spread_angle_deg)
    %BulletSpeed.set_value(gun.bullet_stats.speed)
    %PierceCount.set_value(gun.bullet_stats.pierce_count)
    %Range.set_value(gun.bullet_stats.fly_range)
