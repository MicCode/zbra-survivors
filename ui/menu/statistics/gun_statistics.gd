extends PanelContainer

@export var subtitle_label: String = "SUBTITLE_EQUIPPED_GUN"
@export var is_current_gun: bool = true

var gun: Gun
var compare_to: Gun

func _ready() -> void:
    refresh_display()
    if is_current_gun and GameState.equipped_gun != null:
        change_gun(GameState.equipped_gun, "")
        GameState.equipped_gun_changed.connect(change_gun)

func change_gun(new_gun: Gun, _previous_gun_name: String):
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

    var gun_stats: GunStats = gun.gun_stats
    var compare_to_gun_stats: GunStats
    var base_gun_stats: GunStats = GameState.base_equipped_gun_stats

    var bullet_stats: BulletStats = gun.bullet_stats
    var compare_to_bullet_stats: BulletStats
    var base_bullet_stats: BulletStats = GameState.base_equipped_bullet_stats

    if bullet_stats.inflicts_fire:
        %FireDamagePerS.show()
    else:
        %FireDamagePerS.hide()

    if bullet_stats.is_explosive:
        %ExplosionDamage.show()
        %ExplosionRadius.show()
    else:
        %ExplosionDamage.hide()
        %ExplosionRadius.hide()

    if compare_to:
        compare_to_gun_stats = compare_to.gun_stats
        compare_to_bullet_stats = compare_to.bullet_stats

    var diff_color = "46ce00"

    %Stats.show()
    %NoGun.hide()

    %SubtitleLabel.text = tr(subtitle_label)
    %GunName.text = tr(gun_stats.display_name)

    %Damage.set_value(bullet_stats.damage)
    if compare_to:
        %Damage.set_compare_to(compare_to_bullet_stats.damage)
    elif bullet_stats.damage != base_bullet_stats.damage:
        %Damage.set_compare_to(base_bullet_stats.damage, false, diff_color)

    %DamagePerS.set_value(Conversions.dps(gun_stats, bullet_stats))
    if compare_to: %DamagePerS.set_compare_to(Conversions.dps(compare_to_gun_stats, compare_to_bullet_stats))
    elif Conversions.dps(gun_stats, bullet_stats) != Conversions.dps(base_gun_stats, base_bullet_stats):
        %DamagePerS.set_compare_to(Conversions.dps(base_gun_stats, base_bullet_stats), false, diff_color)

    var fire_dps = bullet_stats.fire_damage * bullet_stats.fire_tick_per_s
    var base_fire_dps = base_bullet_stats.fire_damage * base_bullet_stats.fire_tick_per_s
    %FireDamagePerS.set_value(fire_dps)
    if compare_to: %FireDamagePerS.set_compare_to(compare_to_bullet_stats.fire_damage * compare_to_bullet_stats.fire_tick_per_s)
    elif fire_dps != base_fire_dps:
        %FireDamagePerS.set_compare_to(base_fire_dps, false, diff_color)

    %ExplosionDamage.set_value(bullet_stats.explosion_damage)
    if compare_to: %ExplosionDamage.set_compare_to(compare_to_bullet_stats.explosion_damage)
    elif bullet_stats.explosion_damage != base_bullet_stats.explosion_damage:
        %ExplosionDamage.set_compare_to(base_bullet_stats.explosion_damage, false, diff_color)

    %ExplosionRadius.set_value(bullet_stats.explosion_radius)
    if compare_to: %ExplosionRadius.set_compare_to(compare_to_bullet_stats.explosion_radius)
    elif bullet_stats.explosion_radius != base_bullet_stats.explosion_radius:
        %ExplosionRadius.set_compare_to(base_bullet_stats.explosion_radius, false, diff_color)

    %ShotPerS.set_value(gun_stats.shots_per_s)
    if compare_to: %ShotPerS.set_compare_to(compare_to_gun_stats.shots_per_s)
    elif gun_stats.shots_per_s != base_gun_stats.shots_per_s:
        %ShotPerS.set_compare_to(base_gun_stats.shots_per_s, false, diff_color)

    %BulletsPerShot.set_value(gun_stats.bullets_per_shot)
    if compare_to: %BulletsPerShot.set_compare_to(compare_to_gun_stats.bullets_per_shot)
    elif gun_stats.bullets_per_shot != base_gun_stats.bullets_per_shot:
        %BulletsPerShot.set_compare_to(base_gun_stats.bullets_per_shot, false, diff_color)

    %SpreadAngle.set_value(gun_stats.bullets_spread_angle_deg)
    if compare_to: %SpreadAngle.set_compare_to(compare_to_gun_stats.bullets_spread_angle_deg)
    elif gun_stats.bullets_spread_angle_deg != base_gun_stats.bullets_spread_angle_deg:
        %SpreadAngle.set_compare_to(base_gun_stats.bullets_spread_angle_deg, false, diff_color)

    %BulletSpeed.set_value(Conversions.game_speed_to_kmh(bullet_stats.speed))
    if compare_to: %BulletSpeed.set_compare_to(Conversions.game_speed_to_kmh(compare_to_bullet_stats.speed))
    elif bullet_stats.speed != base_bullet_stats.speed:
        %BulletSpeed.set_compare_to(Conversions.game_speed_to_kmh(base_bullet_stats.speed), false, diff_color)

    %PierceCount.set_value(bullet_stats.pierce_count)
    if compare_to: %PierceCount.set_compare_to(compare_to_bullet_stats.pierce_count)
    elif bullet_stats.pierce_count != base_bullet_stats.pierce_count:
        %PierceCount.set_compare_to(base_bullet_stats.pierce_count, false, diff_color)

    %Range.set_value(Conversions.game_pixels_to_m(bullet_stats.fly_range))
    if compare_to: %Range.set_compare_to(Conversions.game_pixels_to_m(compare_to_bullet_stats.fly_range))
    elif bullet_stats.fly_range != base_bullet_stats.fly_range:
        %Range.set_compare_to(Conversions.game_pixels_to_m(base_bullet_stats.fly_range), false, diff_color)
