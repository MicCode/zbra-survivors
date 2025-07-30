extends PanelContainer

@export var subtitle_label: String = "SUBTITLE_EQUIPPED_GUN"
@export var is_current_gun: bool = true

var gun: Gun
var compare_to: Gun

func _ready() -> void:
    refresh_display()
    if is_current_gun and GameState.equipped_gun != null:
        change_gun(GameState.equipped_gun)
        GameState.equipped_gun_changed.connect(change_gun)

func change_gun(new_gun: Gun):
    gun = new_gun
    %GunSlot.change_gun(new_gun)
    refresh_display()

func change_compare_to(new_gun: Gun):
    compare_to = new_gun
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
    if compare_to: %Damage.set_compare_to(compare_to.bullet_stats.damage)

    %DamagePerS.set_value(gun.get_dps())
    if compare_to: %DamagePerS.set_compare_to(compare_to.get_dps())

    %ShotPerS.set_value(gun.gun_stats.shots_per_s)
    if compare_to: %ShotPerS.set_compare_to(compare_to.gun_stats.shots_per_s)

    %BulletsPerShot.set_value(gun.gun_stats.bullets_per_shot)
    if compare_to: %BulletsPerShot.set_compare_to(compare_to.gun_stats.bullets_per_shot)

    %SpreadAngle.set_value(gun.gun_stats.bullets_spread_angle_deg)
    if compare_to: %SpreadAngle.set_compare_to(compare_to.gun_stats.bullets_spread_angle_deg)

    %BulletSpeed.set_value(Conversions.game_speed_to_kmh(gun.bullet_stats.speed))
    if compare_to: %BulletSpeed.set_compare_to(Conversions.game_speed_to_kmh(compare_to.bullet_stats.speed))

    %PierceCount.set_value(gun.bullet_stats.pierce_count)
    if compare_to: %PierceCount.set_compare_to(compare_to.bullet_stats.pierce_count)

    %Range.set_value(Conversions.game_pixels_to_m(gun.bullet_stats.fly_range))
    if compare_to: %Range.set_compare_to(Conversions.game_pixels_to_m(compare_to.bullet_stats.fly_range))
