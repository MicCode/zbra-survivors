extends PanelContainer

func _ready() -> void:
    refresh_display()
    GameState.equipped_gun_changed.connect(func(_gun): refresh_display())

func refresh_display():
    if GameState.equipped_gun == null:
        %Stats.hide()
        %NoGun.show()
        return
    %Stats.show()
    %NoGun.hide()

    %GunName.text = tr(GameState.equipped_gun.gun_stats.display_name)

    %Damage.set_value(GameState.equipped_gun.bullet_stats.damage)
    %DamagePerS.set_value(GameState.equipped_gun.get_dps())
    %ShotPerS.set_value(GameState.equipped_gun.gun_stats.shots_per_s)
    %BulletsPerShot.set_value(GameState.equipped_gun.gun_stats.bullets_per_shot)
    %SpreadAngle.set_value(GameState.equipped_gun.gun_stats.bullets_spread_angle_deg)
    %BulletSpeed.set_value(GameState.equipped_gun.bullet_stats.speed)
    %PierceCount.set_value(GameState.equipped_gun.bullet_stats.pierce_count)
    %Range.set_value(GameState.equipped_gun.bullet_stats.fly_range)
