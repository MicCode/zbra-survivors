extends CanvasLayer

var equipped_gun: Gun
var gun_stats: GunStats
var bullet_stats: BulletStats

func _ready() -> void:
    GameState.equipped_gun_changed.connect(_on_equipped_gun_changed)
    GameState.game_paused_changed.connect(func(is_game_paused: bool):
        if is_game_paused: %Modulator.color = Color.TRANSPARENT
        else: %Modulator.color = Color.WHITE
    )

func init(_gun_stats: GunStats, _bullet_stats: BulletStats):
    gun_stats = _gun_stats
    bullet_stats = _bullet_stats
    if !gun_stats:
        push_warning("gun info panel has no gun_stats defined, falling back to default")
        gun_stats = load("res://equipment/guns/_generics/stats/default_gun_stats.tres")
    if !bullet_stats:
        push_warning("gun info panel has no bullet_stats defined, falling back to default")
        bullet_stats = load("res://equipment/guns/_generics/stats/default_bullet_stats.tres")

    update_displayed_stats()


func _on_equipped_gun_changed(new_gun: Gun):
    equipped_gun = new_gun
    update_displayed_stats()
    if equipped_gun && gun_stats && bullet_stats:
        %GunName.text = gun_stats.display_name.to_upper()
        %Attack.modulate = get_modulation_color(bullet_stats.damage, equipped_gun.bullet_stats.damage)
        %DPS.modulate = get_modulation_color(get_dps(gun_stats, bullet_stats), get_dps(equipped_gun.gun_stats, equipped_gun.bullet_stats))
        %Reload.modulate = get_modulation_color(gun_stats.shots_per_s, equipped_gun.gun_stats.shots_per_s)
        %BulletsCount.modulate = get_modulation_color(gun_stats.bullets_per_shot, equipped_gun.gun_stats.bullets_per_shot)
        %Angle.modulate = get_modulation_color(gun_stats.bullets_spread_angle_deg, equipped_gun.gun_stats.bullets_spread_angle_deg, true)

func update_displayed_stats():
    if gun_stats && bullet_stats:
        %GunName.text = gun_stats.display_name.to_upper()
        %Attack.text = str(bullet_stats.damage)
        %DPS.text = str(get_dps(gun_stats, bullet_stats))
        %Reload.text = str(gun_stats.shots_per_s)
        %BulletsCount.text = str(gun_stats.bullets_per_shot)
        %Angle.text = str(gun_stats.bullets_spread_angle_deg) + "°"
        if equipped_gun:
            %Attack.text += get_diff(bullet_stats.damage, equipped_gun.bullet_stats.damage)
            %DPS.text += get_diff(get_dps(gun_stats, bullet_stats), get_dps(equipped_gun.gun_stats, equipped_gun.bullet_stats))
            %Reload.text += get_diff(gun_stats.shots_per_s, equipped_gun.gun_stats.shots_per_s)
            %BulletsCount.text += get_diff(gun_stats.bullets_per_shot, equipped_gun.gun_stats.bullets_per_shot)
            %Angle.text += get_diff(gun_stats.bullets_spread_angle_deg, equipped_gun.gun_stats.bullets_spread_angle_deg)

func get_modulation_color(a: float, b: float, invert = false) -> Color:
    if !invert && a > b || invert && a < b:
        return Color("#00ff00")
    elif !invert && a < b || invert && a > b:
        return Color("#d90000")
    else:
        return Color("#000000")

func get_diff(a: float, b: float) -> String:
    var diff = a - b
    if diff < 0:
        return " (" + str(diff) + ")" # already has the - sign
    elif diff > 0:
        return " (+" + str(diff) + ")"
    else:
        return ""

func get_dps(_gun_stats: GunStats, _bullet_stats: BulletStats) -> float:
    return _bullet_stats.damage * _gun_stats.bullets_per_shot * _gun_stats.shots_per_s
