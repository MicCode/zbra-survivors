extends Node
signal player_state_changed
signal score_changed
signal player_gained_level
signal equipped_gun_changed


var player_state: PlayerState
var player_instance: Player
var score: int = 0
var spawn_time_s: float = 3.0
var equipped_gun: Gun

func _init() -> void:
	player_state = PlayerState.new()

func increment_score(i: int):
	score += i
	emit_score_change()
	
func gain_xp(xp: float):
	player_state.xp += xp
	if player_state.xp >= player_state.next_level_xp:
		var excess = player_state.xp - player_state.next_level_xp
		player_state.xp = excess
		player_state.next_level_xp += player_state.next_level_xp / 4
		player_state.level += 1 #TODO we should test if excess is still superior to next_level_xp and add more level if necessary
		player_gained_level.emit(player_state.level)
		
	emit_player_change()

func emit_player_change():
	player_state_changed.emit(player_state)

func emit_score_change():
	score_changed.emit(score)

func register_player_instance(_player):
	player_instance = _player

func change_equipped_gun(_new_gun: Gun):
	equipped_gun = _new_gun
	equipped_gun_changed.emit(equipped_gun)
