extends PanelContainer

func _ready() -> void:
    refresh_stats()
    PlayerService.player_stats_changed.connect(func(_state): refresh_stats())

func refresh_stats():
    var player_stats = PlayerService.player_stats
    var base_stats = PlayerService.base_player_stats
    var diff_color = "46ce00"

    %Health.set_value(player_stats.health)
    %Xp.set_value(player_stats.xp)
    %NextLevelXp.set_value(player_stats.next_level_xp)
    %Level.set_value(player_stats.level)

    %MaxHealth.set_value(player_stats.max_health)
    if player_stats.max_health != base_stats.max_health:
        %MaxHealth.set_compare_to(base_stats.max_health, false, diff_color)

    %XpCollectRadius.set_value(Conversions.game_pixels_to_m(player_stats.xp_collect_radius))
    if player_stats.xp_collect_radius != base_stats.xp_collect_radius:
        %XpCollectRadius.set_compare_to(Conversions.game_pixels_to_m(base_stats.xp_collect_radius), false, diff_color)

    %MoveSpeed.set_value(Conversions.game_speed_to_kmh(player_stats.move_speed))
    if player_stats.move_speed != base_stats.move_speed:
        %MoveSpeed.set_compare_to(Conversions.game_speed_to_kmh(base_stats.move_speed), false, diff_color)

    %DashDuration.set_value(player_stats.dash_duration)
    if player_stats.dash_duration != base_stats.dash_duration:
        %DashDuration.set_compare_to(base_stats.dash_duration, false, diff_color)

    %DashCooldown.set_value(player_stats.dash_cooldown)
    if player_stats.dash_cooldown != base_stats.dash_cooldown:
        %DashCooldown.set_compare_to(base_stats.dash_cooldown, false, diff_color)

    %DashSpeed.set_value(Conversions.game_speed_to_kmh(player_stats.move_speed * player_stats.dash_speed_multiplier))
    if player_stats.dash_speed_multiplier != base_stats.dash_speed_multiplier:
        %DashSpeed.set_compare_to(Conversions.game_speed_to_kmh(base_stats.move_speed * base_stats.dash_speed_multiplier), false, diff_color)

    %ExplosionsDamage.set_value(PlayerService.explosions_damage)
    if PlayerService.explosions_damage != PlayerService.base_explosions_damage:
        %ExplosionsDamage.set_compare_to(PlayerService.base_explosions_damage, false, diff_color)

    %ExplosionsRadius.set_value(PlayerService.explosions_radius)
    if PlayerService.explosions_radius != PlayerService.base_explosions_radius:
        %ExplosionsRadius.set_compare_to(PlayerService.base_explosions_radius, false, diff_color)
