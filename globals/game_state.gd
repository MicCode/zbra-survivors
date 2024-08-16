extends Node
signal player_state_changed
signal score_changed


var player: PlayerState
var score: int = 0
var spawn_time_s: float = 3.0

func _init() -> void:
    player = PlayerState.new()

func increment_score(i: int):
    score += i
    emit_score_change()

func emit_player_change():
    player_state_changed.emit(player)

func emit_score_change():
    score_changed.emit(score)
