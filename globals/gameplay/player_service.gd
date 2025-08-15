extends Node
signal notify_level_gain
signal player_stats_changed
signal player_gained_xp(amount: float)
signal player_gained_level(number_of_gained_levels: int)
signal player_timewarping_changed(timewarping: bool)
signal player_moved(position: Vector2)
signal player_openned_chest()
signal consumable_changed(new_consumable: ConsumableItem)
signal consumable_use_changed(use: int)

const MAX_PLAYER_LEVEL: int = 100
const XP_INCREASE_PERCENT_PER_LEVEL: float = 25.0

var player_instance: Player
var base_player_stats: PlayerStats
var player_stats: PlayerStats

var explosions_damage: float = 100.0
var base_explosions_damage: float = 100.0
var explosions_radius: float = 100.0
var base_explosions_radius: float = 100.0

var consumable: ConsumableItem

var lvl_up_exclusions_remaining: int = 3
var lvl_up_rerolls_remaining: int = 3

func reset():
    base_player_stats = load("res://player/stats/default_player_stats.tres")
    player_stats = base_player_stats.duplicate(true)
    lvl_up_exclusions_remaining = 3 # TODO put base value in settings ?
    lvl_up_rerolls_remaining = 3 # TODO put base value in settings ?

    change_consumable(null)
    emit_player_change()

func gain_xp(xp: float) -> void:
    player_stats.xp += xp
    player_stats.total_xp += xp
    player_gained_xp.emit(xp)

    var new_level_gained = 0
    while player_stats.xp >= player_stats.next_level_xp:
        var excess = player_stats.xp - player_stats.next_level_xp
        player_stats.xp = excess
        player_stats.next_level_xp = Utils.add_percent(player_stats.next_level_xp, XP_INCREASE_PERCENT_PER_LEVEL)
        player_stats.level += 1
        new_level_gained += 1

    if new_level_gained > 0:
        player_gained_level.emit(new_level_gained)
        if !GameService.first_level_gained:
            GameService.first_level_gained = true
            MusicManager.update_music_intensity()
    emit_player_change()

func change_consumable(_new_consumable: ConsumableItem) -> void:
    if _new_consumable:
        consumable = _new_consumable.duplicate()
    else:
        consumable = null
    # print("should emit new consumable: " + str(_new_consumable))
    consumable_changed.emit(consumable)

func emit_player_change() -> void:
    player_stats_changed.emit(player_stats)

func register_player_instance(_player) -> void:
    player_instance = _player
    player_moved.emit(player_instance.global_position)
