extends Node
signal player_state_changed
signal score_changed
signal player_gained_level(new_level: int)
signal equipped_gun_changed(new_gun: Gun)
signal consumable_changed(new_consumable: ConsumableItem)
signal consumable_use_changed(use: int)
signal player_timewarping_changed(timewarping: bool)
signal player_moved(position: Vector2)
signal boss_changed(boss_stats: EnnemyStats, boss_health: float)
signal state_changed(new_state: State)
signal shake_screen(strength: float)

enum State {
    NOT_STARTED,
    RUNNING,
    PAUSED,
    GAME_OVER
}

var player_instance: Player

var base_player_state: PlayerState
var player_state: PlayerState
var player_stats_modifiers: Array[PlayerStatModifier] = []

var equipped_gun: Gun
var consumable: ConsumableItem

var state: State = State.NOT_STARTED
var score: int = 0
var spawn_time_s: float = 2.0 # TODO this has to be reworked to be set accordingly to the game progression

var pause_menu: PauseMenu
var gun_change_menu: GunChangeMenu

## Resets all game state info, like if the game was freshly started
func reset() -> void:
    _reset_player()
    score = 0
    spawn_time_s = 2.0
    change_equipped_gun(null)
    change_consumable(null)
    emit_player_change()
    emit_score_change()
    boss_changed.emit(null, 0.0)
    change_state(State.RUNNING)

func _init() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    _reset_player()
    change_state(State.RUNNING)

func _reset_player():
    player_stats_modifiers = []
    base_player_state = preload("res://player/state/default_player_state.tres").duplicate()
    player_state = base_player_state.duplicate(true)

func _input(event):
    if event.is_action_pressed("pause_game") && state != State.GAME_OVER:
        if state == State.PAUSED:
            if pause_menu:
                Sounds.click()
                pause_menu.slide_out().finished.connect(func():
                    pause_menu.queue_free()
                    change_state(State.RUNNING)
                )
        else:
            Sounds.click()
            pause_menu = preload("res://ui/menu/pause_menu.tscn").instantiate()
            get_tree().root.add_child(pause_menu)
            change_state(State.PAUSED)

func change_state(new_state: State):
    state = new_state
    state_changed.emit(new_state)
    if State.GAME_OVER == state:
        show_game_over()
    if is_inside_tree():
        if [State.PAUSED, State.GAME_OVER].has(state):
            get_tree().paused = true
        else:
            get_tree().paused = false

func increment_score(i: int) -> void:
    score += i
    emit_score_change()

func gain_xp(xp: float) -> void:
    player_state.xp += xp
    if player_state.xp >= player_state.next_level_xp:
        var excess = player_state.xp - player_state.next_level_xp
        player_state.xp = excess
        player_state.next_level_xp += player_state.next_level_xp / 4
        player_state.level += 1 # TODO we should test if excess is still superior to next_level_xp and add more level if necessary
        player_gained_level.emit(player_state.level)

    emit_player_change()

func add_player_stat_modifier(new_modifier: PlayerStatModifier):
    var existing_modifiers: Array[PlayerStatModifier] = player_stats_modifiers.filter(func(m: PlayerStatModifier): return m.stat_name == new_modifier.stat_name)
    if existing_modifiers.is_empty():
        player_stats_modifiers.append(new_modifier.duplicate(true))
    else:
        existing_modifiers[0].modifier_value += new_modifier.modifier_value
        # TODO what if multiple matching modifiers are found ?
    player_state = PlayerState.duplicate_with_modifiers(base_player_state, player_stats_modifiers)
    emit_player_change()


func emit_player_change() -> void:
    player_state_changed.emit(player_state)

func emit_score_change() -> void:
    score_changed.emit(score)

func register_player_instance(_player) -> void:
    player_instance = _player

func change_equipped_gun(_new_gun: Gun) -> GunChangeMenu:
    if !equipped_gun:
        # do not display the gun swap menu the first time a gun is picked up
        equipped_gun = _new_gun
        equipped_gun_changed.emit(equipped_gun)
        return null

    gun_change_menu = preload("res://ui/menu/gun_change_menu.tscn").instantiate()
    gun_change_menu.change_proposed_gun(_new_gun)
    get_tree().root.add_child(gun_change_menu)
    change_state(State.PAUSED)

    gun_change_menu.take_pressed.connect(func():
        equipped_gun = _new_gun
        equipped_gun_changed.emit(equipped_gun)
        gun_change_menu.call_deferred("queue_free")
        change_state(State.RUNNING)
    )
    gun_change_menu.keep_pressed.connect(func():
        gun_change_menu.queue_free()
        change_state(State.RUNNING)
    )
    return gun_change_menu

func change_consumable(_new_consumable: ConsumableItem) -> void:
    if _new_consumable:
        consumable = _new_consumable.duplicate()
    else:
        consumable = null
    # print("should emit new consumable: " + str(_new_consumable))
    consumable_changed.emit(consumable)

func register_ennemy_death(ennemy: Ennemy) -> void:
    increment_score(1)
    drop_item(preload("res://player/xp_drop.tscn").instantiate().with_value(ennemy.stats.xp_value), ennemy.global_position)
    Announcer.ennemy_died()

    # TODO implement a better random loot system
    if randf() <= GameState.player_state.life_drop_chance:
        drop_item(preload("res://items/consumables/life_flask/life_flask.tscn").instantiate().with_life_amount(1), ennemy.global_position)
    if randf() <= GameState.player_state.radiance_drop_chance:
        drop_item(preload("res://items/consumables/radiance_flask/radiance_flask.tscn").instantiate(), ennemy.global_position)
    if randf() <= GameState.player_state.timewrap_drop_change:
        drop_item(preload("res://items/consumables/timewrap_clock/timewrap_clock.tscn").instantiate(), ennemy.global_position)
    if randf() <= GameState.player_state.xp_collector_drop_chance:
        drop_item(preload("res://items/consumables/xp_collector/xp_collector.tscn").instantiate(), ennemy.global_position)
    if randf() <= GameState.player_state.land_mine_chance:
        drop_item(preload("res://items/consumables/mine/mine_collectible.tscn").instantiate(), ennemy.global_position)

func drop_item(item: Node2D, position: Vector2) -> void:
    item.global_position = position
    SceneManager.current_scene.call_deferred("add_child", item)

func show_game_over() -> void:
    var current_scene = SceneManager.current_scene
    if current_scene:
        var game_over_menu = preload("res://ui/menu/game_over_menu.tscn").instantiate()
        current_scene.add_child(game_over_menu)
