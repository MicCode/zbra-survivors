extends Node
signal player_state_changed
signal score_changed
signal player_gained_level
signal equipped_gun_changed

signal player_timewarping_changed(timewarping: bool)
signal player_moved(position: Vector2)

signal boss_changed(boss_stats: EnnemyStats, boss_health: float)

var player_state: PlayerState
var player_instance: Player

var score: int = 0
var spawn_time_s: float = 3.0
var equipped_gun: Gun
var is_game_over = false

## Resets all game state info, like if the game was freshly started
func reset() -> void:
    player_state = PlayerState.new()
    score = 0
    spawn_time_s = 3.0
    equipped_gun = null
    is_game_over = false
    emit_player_change()
    emit_score_change()
    boss_changed.emit(null, 0.0)

func _init() -> void:
    player_state = PlayerState.new()

func increment_score(i: int) -> void:
    score += i
    emit_score_change()

func set_game_over(_is_game_over: bool):
    is_game_over = _is_game_over
    if is_game_over:
        show_game_over()

func gain_xp(xp: float) -> void:
    player_state.xp += xp
    if player_state.xp >= player_state.next_level_xp:
        var excess = player_state.xp - player_state.next_level_xp
        player_state.xp = excess
        player_state.next_level_xp += player_state.next_level_xp / 4
        player_state.level += 1 # TODO we should test if excess is still superior to next_level_xp and add more level if necessary
        player_gained_level.emit(player_state.level)

    emit_player_change()

func emit_player_change() -> void:
    player_state_changed.emit(player_state)

func emit_score_change() -> void:
    score_changed.emit(score)

func register_player_instance(_player) -> void:
    player_instance = _player

func change_equipped_gun(_new_gun: Gun) -> void:
    equipped_gun = _new_gun
    equipped_gun_changed.emit(equipped_gun)

func register_ennemy_death(ennemy: Ennemy) -> void:
    increment_score(1)
    drop_item(preload("res://player/xp_drop.tscn").instantiate().with_value(ennemy.stats.xp_value), ennemy.global_position)

    if randf() <= GameService.player_state.life_drop_chance:
        drop_item(preload("res://equipment/items/life_flask.tscn").instantiate().with_life_amount(1), ennemy.global_position)
    elif randf() <= GameService.player_state.radiance_drop_chance:
        drop_item(preload("res://equipment/items/radiance_flask.tscn").instantiate(), ennemy.global_position)
    elif randf() <= GameService.player_state.timewrap_drop_change:
        drop_item(preload("res://equipment/items/timewrap_clock.tscn").instantiate(), ennemy.global_position)

func drop_item(item: Node2D, position: Vector2) -> void:
    item.global_position = position
    SceneManager.current_scene.call_deferred("add_child", item)

func show_game_over() -> void:
    var current_scene = SceneManager.current_scene
    if current_scene:
        var game_over_menu = preload("res://ui/menu/game_over_menu.tscn").instantiate()
        current_scene.add_child(game_over_menu)
        current_scene.get_tree().paused = true
