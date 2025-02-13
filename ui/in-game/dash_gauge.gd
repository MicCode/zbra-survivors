extends Node2D
class_name DashGauge

enum DashGaugeStates {
	EMPTY,
	LOADING_1,
	LOADING_2,
	LOADING_3,
	LOADING_4,
	FULL,
	USING
}

var state: DashGaugeStates = DashGaugeStates.FULL

func _ready() -> void:
	GameService.player_state_changed.connect(_update_gauge)
	var joypads = Input.get_connected_joypads()
	if joypads.size() > 0:
		%ButtonIcon.key_name = "B"
		%ButtonIcon.controller_name = "xbox"
	else:
		%ButtonIcon.key_name = "SPACE"
		%ButtonIcon.controller_name = "keyboard"
	%ButtonIcon.update_texture()
	
func _update_gauge(new_player_state: PlayerState):
	var new_state = get_new_gauge_state(new_player_state)
	if new_state != state:
		state = new_state
		if state == DashGaugeStates.FULL:
			%ButtonIcon.animate = true
			%ButtonIcon.modulate = Color(1, 1, 1, 1)
		else:
			%ButtonIcon.animate = false
			%ButtonIcon.modulate = Color(1, 1, 1, 0.5)
		update_animation()

func get_new_gauge_state(new_player_state: PlayerState) -> DashGaugeStates:
	if new_player_state.is_dashing:
		return DashGaugeStates.USING
	else:
		match new_player_state.dash_gauge_value:
			1: return DashGaugeStates.LOADING_1
			2: return DashGaugeStates.LOADING_2
			3: return DashGaugeStates.LOADING_3
			4: return DashGaugeStates.LOADING_4
			5: return DashGaugeStates.FULL
			_: return DashGaugeStates.EMPTY

func update_animation():
	match state:
		DashGaugeStates.EMPTY: %Sprite.play("empty")
		DashGaugeStates.LOADING_1: %Sprite.play("loading_1")
		DashGaugeStates.LOADING_2: %Sprite.play("loading_2")
		DashGaugeStates.LOADING_3: %Sprite.play("loading_3")
		DashGaugeStates.LOADING_4: %Sprite.play("loading_4")
		DashGaugeStates.FULL: %Sprite.play("full")
		DashGaugeStates.USING: %Sprite.play("using")
