extends PanelContainer

func _ready() -> void:
    refresh_stats()
    GameState.player_state_changed.connect(func(_state): refresh_stats())

func refresh_stats():
    var player_state = GameState.player_state
    var base_state = GameState.base_player_state
    var diff_color = "46ce00"

    %Health.set_value(player_state.health)
    %Xp.set_value(player_state.xp)
    %NextLevelXp.set_value(player_state.next_level_xp)
    %Level.set_value(player_state.level)

    %MaxHealth.set_value(player_state.max_health)
    if player_state.max_health != base_state.max_health:
        %MaxHealth.set_compare_to(base_state.max_health, false, diff_color)

    %XpCollectRadius.set_value(Conversions.game_pixels_to_m(player_state.xp_collect_radius))
    if player_state.xp_collect_radius != base_state.xp_collect_radius:
        %XpCollectRadius.set_compare_to(Conversions.game_pixels_to_m(base_state.xp_collect_radius), false, diff_color)

    %MoveSpeed.set_value(Conversions.game_speed_to_kmh(player_state.move_speed))
    if player_state.move_speed != base_state.move_speed:
        %MoveSpeed.set_compare_to(Conversions.game_speed_to_kmh(base_state.move_speed), false, diff_color)

    %DashDuration.set_value(player_state.dash_duration)
    if player_state.dash_duration != base_state.dash_duration:
        %DashDuration.set_compare_to(base_state.dash_duration, false, diff_color)

    %DashCooldown.set_value(player_state.dash_cooldown)
    if player_state.dash_cooldown != base_state.dash_cooldown:
        %DashCooldown.set_compare_to(base_state.dash_cooldown, false, diff_color)

    %DashSpeed.set_value(Conversions.game_speed_to_kmh(player_state.move_speed * player_state.dash_speed_multiplier))
    if player_state.dash_speed_multiplier != base_state.dash_speed_multiplier:
        %DashSpeed.set_compare_to(Conversions.game_speed_to_kmh(base_state.move_speed * base_state.dash_speed_multiplier), false, diff_color)
