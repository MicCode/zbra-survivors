extends PanelContainer
class_name WeaponStatistics

@export var subtitle_label: String = "SUBTITLE_EQUIPPED_WEAPON"
@export var is_current_weapon: bool = true

var weapon: Weapon
var compare_to: Weapon

func _ready() -> void:
    refresh_display()
    if is_current_weapon and WeaponService.equipped_weapon != null:
        change_weapon(WeaponService.equipped_weapon, "")
        WeaponService.equipped_weapon_changed.connect(change_weapon)

func change_weapon(new_weapon: Weapon, _previous_weapon_name: String):
    weapon = new_weapon
    %WeaponSlot.change_weapon(new_weapon)
    refresh_display()

func change_compare_to(other_weapon: Weapon):
    compare_to = other_weapon
    refresh_display()

func refresh_display():
    if is_current_weapon && !weapon:
        %Stats.hide()
        %NoWeapon.show()
        return
    if !is_current_weapon && !weapon:
        push_error("Tried to display weapon statistics without weapon defined")
        %Stats.hide()
        return

    var weapon_stats: WeaponStats = weapon.weapon_stats
    var compare_to_weapon_stats: WeaponStats
    var base_weapon_stats: WeaponStats = WeaponService.base_equipped_weapon_stats

    var bullet_stats: BulletStats = weapon.bullet_stats
    var compare_to_bullet_stats: BulletStats
    var base_bullet_stats: BulletStats = WeaponService.base_equipped_bullet_stats

    var weapon_description = weapon.get_weapon_description()
    if weapon_description.length() > 0:
        %WeaponDescription.text = weapon_description
        %WeaponDescription.show()
    else:
        %WeaponDescription.hide()

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
        compare_to_weapon_stats = compare_to.weapon_stats
        compare_to_bullet_stats = compare_to.bullet_stats

    var diff_color = "46ce00"

    %Stats.show()
    %NoWeapon.hide()

    %SubtitleLabel.text = tr(subtitle_label)
    %WeaponName.text = "WEAPON_" + weapon.get_weapon_name().to_upper()

    # TODO refactor this crap

    %Damage.set_value(bullet_stats.damage)
    if compare_to:
        %Damage.set_compare_to(compare_to_bullet_stats.damage)
    elif bullet_stats.damage != base_bullet_stats.damage:
        %Damage.set_compare_to(base_bullet_stats.damage, false, diff_color)

    %DamagePerS.set_value(Conversions.dps(weapon_stats, bullet_stats))
    if compare_to: %DamagePerS.set_compare_to(Conversions.dps(compare_to_weapon_stats, compare_to_bullet_stats))
    elif Conversions.dps(weapon_stats, bullet_stats) != Conversions.dps(base_weapon_stats, base_bullet_stats):
        %DamagePerS.set_compare_to(Conversions.dps(base_weapon_stats, base_bullet_stats), false, diff_color)

    var fire_dps = bullet_stats.fire_damage * bullet_stats.fire_tick_per_s
    var base_fire_dps = base_bullet_stats.fire_damage * base_bullet_stats.fire_tick_per_s
    %FireDamagePerS.set_value(fire_dps)
    if compare_to: %FireDamagePerS.set_compare_to(compare_to_bullet_stats.fire_damage * compare_to_bullet_stats.fire_tick_per_s)
    elif fire_dps != base_fire_dps:
        %FireDamagePerS.set_compare_to(base_fire_dps, false, diff_color)

    var explosion_damage = bullet_stats.explosion_damage * (PlayerService.explosions_damage / 100)
    var base_explosion_damage = bullet_stats.explosion_damage
    %ExplosionDamage.set_value(explosion_damage)
    if compare_to:
        var other_explosion_damage = compare_to_bullet_stats.explosion_damage * (PlayerService.explosions_damage / 100)
        %ExplosionDamage.set_compare_to(other_explosion_damage)
    elif explosion_damage != base_explosion_damage:
        %ExplosionDamage.set_compare_to(base_explosion_damage, false, diff_color)

    var explosion_radius = bullet_stats.explosion_radius * (PlayerService.explosions_radius / 100)
    var base_explosion_radius = bullet_stats.explosion_radius
    %ExplosionRadius.set_value(explosion_radius)
    if compare_to:
        var other_explosion_radius = compare_to_bullet_stats.explosion_radius * (PlayerService.explosions_radius / 100)
        %ExplosionRadius.set_compare_to(other_explosion_radius)
    elif explosion_radius != base_explosion_radius:
        %ExplosionRadius.set_compare_to(base_explosion_radius, false, diff_color)

    %ShotPerS.set_value(weapon_stats.shots_per_s)
    if compare_to: %ShotPerS.set_compare_to(compare_to_weapon_stats.shots_per_s)
    elif weapon_stats.shots_per_s != base_weapon_stats.shots_per_s:
        %ShotPerS.set_compare_to(base_weapon_stats.shots_per_s, false, diff_color)

    %BulletsPerShot.set_value(weapon_stats.bullets_per_shot)
    if compare_to: %BulletsPerShot.set_compare_to(compare_to_weapon_stats.bullets_per_shot)
    elif weapon_stats.bullets_per_shot != base_weapon_stats.bullets_per_shot:
        %BulletsPerShot.set_compare_to(base_weapon_stats.bullets_per_shot, false, diff_color)

    %SpreadAngle.set_value(weapon_stats.bullets_spread_angle_deg)
    if compare_to: %SpreadAngle.set_compare_to(compare_to_weapon_stats.bullets_spread_angle_deg)
    elif weapon_stats.bullets_spread_angle_deg != base_weapon_stats.bullets_spread_angle_deg:
        %SpreadAngle.set_compare_to(base_weapon_stats.bullets_spread_angle_deg, false, diff_color)

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
