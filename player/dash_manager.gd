extends Node2D

signal can_dash_changed(can_dash: bool)
signal is_dashing_changed(is_dashing: bool)

var dash_duration: float = 1.0
var dash_cooldown: float = 3.0
var dash_ghost_interval: float = 0.01
var timewarp_ghost_interval: float = 0.5
var dash_cooldown_timer: SceneTreeTimer

func _ready() -> void:
    dash_duration = GameState.player_state.dash_duration
    dash_cooldown = GameState.player_state.dash_cooldown
    GameState.player_state_changed.connect(func(player_state: PlayerState):
        dash_duration = player_state.dash_duration
        dash_cooldown = player_state.dash_cooldown
    )

func set_is_dashing(_is_dashing: bool):
    GameState.player_state.is_dashing = _is_dashing
    is_dashing_changed.emit(GameState.player_state.is_dashing)
    GameState.player_state_changed.emit(GameState.player_state)

func is_dashing() -> bool:
    return GameState.player_state.is_dashing

func set_can_dash(_can_dash: bool):
    GameState.player_state.can_dash = _can_dash
    can_dash_changed.emit(GameState.player_state.can_dash)
    GameState.player_state_changed.emit(GameState.player_state)

func can_dash() -> bool:
    return GameState.player_state.can_dash

func start_dashing():
    Sounds.dash()
    get_tree().create_timer(dash_duration).timeout.connect(func():
        if GameState.player_state.is_dashing:
            set_is_dashing(false)
    )
    dash_cooldown_timer = get_tree().create_timer(dash_cooldown)
    dash_cooldown_timer.timeout.connect(func():
        if !GameState.player_state.can_dash:
            Sounds.dash_ready()
            set_can_dash(true)
    )
    set_is_dashing(true)
    set_can_dash(false)
    loop_dash_ghost()

func loop_dash_ghost():
    get_tree().create_timer(dash_ghost_interval).timeout.connect(func():
        spawn_dash_ghost()
        if GameState.player_state.is_dashing:
            get_tree().create_timer(dash_ghost_interval).timeout.connect(loop_dash_ghost)
    )

func spawn_dash_ghost(speed_scale: float = 5.0) -> void:
    var ghost: DashGhost = preload("res://player/dash_ghost.tscn").instantiate()
    ghost.global_position = global_position
    ghost.global_rotation = global_rotation
    ghost.global_scale = global_scale * 1.5 # because sprite is also internally scaled by 1.5
    ghost.z_index = -1
    ghost.speed_scale = speed_scale
    SceneManager.current_scene.add_child(ghost)
