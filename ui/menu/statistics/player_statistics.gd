extends PanelContainer

func _ready() -> void:
    refresh_stats()
    GameState.player_state_changed.connect(func(_state): refresh_stats())

func refresh_stats():
    %Health.set_value(GameState.player_state.health)
    %MaxHealth.set_value(GameState.player_state.max_health)
    %Level.set_value(GameState.player_state.level)
    %Xp.set_value(GameState.player_state.xp)
    %NextLevelXp.set_value(GameState.player_state.next_level_xp)
    %MoveSpeed.set_value(GameState.player_state.move_speed)
    %DashDuration.set_value(GameState.player_state.dash_duration)
    %DashCooldown.set_value(GameState.player_state.dash_cooldown)
