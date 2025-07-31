extends Node
signal player_state_changed
signal player_gained_level(number_of_gained_levels: int)
signal notify_level_gain
signal player_timewarping_changed(timewarping: bool)
signal player_moved(position: Vector2)
signal player_openned_chest()

signal equipped_gun_changed(new_gun: Gun, previous_gun_name: String)
signal gun_stats_changed(new_stats: GunStats)
signal bullet_stats_changed(new_stats: BulletStats)

signal consumable_changed(new_consumable: ConsumableItem)
signal consumable_use_changed(use: int)

signal score_changed
signal boss_changed(boss_stats: EnnemyStats, boss_health: float)
signal state_changed(new_state: State)
signal shake_screen(strength: float)

enum State {
    NOT_STARTED,
    RUNNING,
    PAUSED,
    CHOOSING_UPGRADE,
    GAME_OVER
}

var player_instance: Player

var base_player_state: PlayerState
var player_state: PlayerState
var explosions_damage: float = 100.0
var base_explosions_damage: float = 100.0
var explosions_radius: float = 100.0
var base_explosions_radius: float = 100.0
var stats_modifiers: Array[StatsModifier] = []

var equipped_gun: Gun
var base_equipped_gun_stats: GunStats
var base_equipped_bullet_stats: BulletStats

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
    player_openned_chest.connect(func():
        var random_gun = LootGenerator.get_random_gun()
        change_equipped_gun(random_gun)
    )

func _reset_player():
    stats_modifiers = []
    base_player_state = preload("res://player/state/default_player_state.tres").duplicate()
    player_state = base_player_state.duplicate(true)

func _input(event):
    if event.is_action_pressed("pause_game") and not [State.CHOOSING_UPGRADE, State.GAME_OVER].has(state):
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
        if [State.PAUSED, State.CHOOSING_UPGRADE, State.GAME_OVER].has(state):
            get_tree().paused = true
        else:
            get_tree().paused = false

func increment_score(i: int) -> void:
    score += i
    emit_score_change()

func gain_xp(xp: float) -> void:
    player_state.xp += xp

    var new_level_gained = 0
    while player_state.xp >= player_state.next_level_xp:
        var excess = player_state.xp - player_state.next_level_xp
        player_state.xp = excess
        player_state.next_level_xp += player_state.next_level_xp / 4
        player_state.level += 1
        new_level_gained += 1

    player_gained_level.emit(new_level_gained)
    emit_player_change()

func register_new_modifier(new_mod: Modifiers.Mod):
    var new_stats_modifier = new_mod.to_stats_modifier()
    var existing_modifiers: Array[StatsModifier] = stats_modifiers.filter(func(m: StatsModifier): return m.modifier == new_stats_modifier.modifier)
    if existing_modifiers.is_empty():
        stats_modifiers.append(new_stats_modifier)
    else:
        existing_modifiers[0].modifier_value += new_stats_modifier.modifier_value

    compute_modifiers(new_stats_modifier)

func compute_modifiers(new_stats_modifier: StatsModifier = null):
    player_state = PlayerState.apply_modifiers(base_player_state, stats_modifiers)
    if equipped_gun:
        equipped_gun.gun_stats = GunStats.apply_modifiers(base_equipped_gun_stats, stats_modifiers)
        gun_stats_changed.emit(equipped_gun.gun_stats)
        equipped_gun.bullet_stats = BulletStats.apply_modifiers(base_equipped_bullet_stats, stats_modifiers)
        bullet_stats_changed.emit(equipped_gun.bullet_stats)

    if new_stats_modifier and new_stats_modifier.modifier == Modifiers.Name.PLAYER_MAX_HEALTH:
        player_state.health += new_stats_modifier.modifier_value

    var explosions_modifiers: Array[StatsModifier] = stats_modifiers.filter(func(m: StatsModifier): return m.is_type(Modifiers.Type.EXPLOSION))
    if !explosions_modifiers.is_empty():
        explosions_damage = base_explosions_damage
        explosions_radius = base_explosions_radius
        for mod in explosions_modifiers:
            if mod.modifier == Modifiers.Name.EXPLOSION_RADIUS:
                explosions_radius += mod.modifier_value
            elif mod.modifier == Modifiers.Name.EXPLOSION_DAMAGE:
                explosions_damage += mod.modifier_value

    emit_player_change()


func emit_player_change() -> void:
    player_state_changed.emit(player_state)

func emit_score_change() -> void:
    score_changed.emit(score)

func register_player_instance(_player) -> void:
    player_instance = _player

func change_equipped_gun(_new_gun: Gun) -> GunChangeMenu:
    if !_new_gun:
        equipped_gun = null
        return null

    if !equipped_gun:
        # do not display the gun swap menu the first time a gun is picked up
        equipped_gun = _new_gun
        if _new_gun:
            base_equipped_gun_stats = _new_gun.gun_stats.duplicate(true)
            base_equipped_bullet_stats = _new_gun.bullet_stats.duplicate(true)
        else:
            base_equipped_gun_stats = null
            base_equipped_bullet_stats = null
        compute_modifiers()
        equipped_gun_changed.emit(equipped_gun, "")
        return null

    _new_gun.gun_stats = GunStats.apply_modifiers(_new_gun.gun_stats, stats_modifiers)
    _new_gun.bullet_stats = BulletStats.apply_modifiers(_new_gun.bullet_stats, stats_modifiers)
    gun_change_menu = preload("res://ui/menu/gun_change_menu.tscn").instantiate()
    gun_change_menu.change_proposed_gun(_new_gun)
    get_tree().root.add_child(gun_change_menu)
    change_state(State.PAUSED)

    gun_change_menu.take_pressed.connect(func():
        var previous_gun_name = equipped_gun.gun_stats.name
        equipped_gun = _new_gun
        if _new_gun:
            base_equipped_gun_stats = _new_gun.gun_stats.duplicate(true)
            base_equipped_bullet_stats = _new_gun.bullet_stats.duplicate(true)
        else:
            base_equipped_gun_stats = null
            base_equipped_bullet_stats = null
        compute_modifiers()
        equipped_gun_changed.emit(equipped_gun, previous_gun_name)
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
