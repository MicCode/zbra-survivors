extends Node
signal player_state_changed
signal score_changed


var player_state: PlayerState
var player_instance: Player
var score: int = 0
var spawn_time_s: float = 3.0

func _init() -> void:
	player_state = PlayerState.new()

func increment_score(i: int):
	score += i
	emit_score_change()
	
func gain_xp(xp: float):
	player_state.xp += xp
	emit_player_change()

func emit_player_change():
	player_state_changed.emit(player_state)

func emit_score_change():
	score_changed.emit(score)

func register_player_instance(_player):
	player_instance = _player
