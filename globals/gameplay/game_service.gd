extends Node
signal score_changed
signal boss_changed(boss_stats: EnemyStats, boss_health: float)
signal state_changed(new_state: E.GameState)
signal shake_screen(strength: float)
signal remaining_time_changed(remaining_time: float)

const MAX_ELAPSED_TIME: float = 400.0
const MIN_SPAWN_TIME: float = 0.5

var game_ui_instance: GameUI
var state: E.GameState = E.GameState.NOT_STARTED
var score: int = 0
var is_success = false
var pause_menu: PauseMenu
var elapsed_time: float = 0.0
var first_chest_openned: bool = false
var first_level_gained: bool = false

var music: MusicManager.Music = MusicManager.Music.NOT_SET

func _ready() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    PlayerService.player_openned_chest.connect(func():
        var random_gun = LootService.get_random_gun()
        GunService.change_equipped_gun(random_gun, true)
        if !first_chest_openned:
            first_chest_openned = true
    )

func start_new_game():
    # reset state
    Engine.time_scale = 1.0
    AudioServer.playback_speed_scale = 1.0
    elapsed_time = 0.0
    score = 0
    first_chest_openned = false
    first_level_gained = false
    is_success = false

    ModsService.reset()
    EnemiesService.reset()
    PlayerService.reset()
    LootService.reset()
    GunService.reset()

    ModsService.init_modifiers_chances()

    var possible_musics: Array[MusicManager.Music] = [
        MusicManager.Music.ELECTRO_1,
        MusicManager.Music.ELECTRO_2,
        MusicManager.Music.METAL_1,
    ]
    music = possible_musics.pick_random()
    MusicManager.set_music(music)
    MusicManager.set_layer(E.MusicLayer.SOFT)

    # emit first events to refresh all listening components
    boss_changed.emit(null, 0.0)
    emit_score_change()
    # start game
    GameLogger.start_logging()
    change_state(E.GameState.RUNNING)


func _process(delta: float) -> void:
    var is_current_scene_paused = false
    if SceneManager.current_scene:
        is_current_scene_paused = SceneManager.current_scene.get_tree().paused
    if !get_tree().paused and !is_current_scene_paused and state != E.GameState.PAUSED:
        elapsed_time += delta

func _input(event):
    if event.is_action_pressed("pause_game") and not [E.GameState.NOT_STARTED, E.GameState.CHOOSING_UPGRADE, E.GameState.GAME_OVER].has(state):
        if state == E.GameState.PAUSED:
            if pause_menu:
                Sounds.button_press()
                pause_menu.slide_out().finished.connect(func():
                    pause_menu.queue_free()
                    change_state(E.GameState.RUNNING)
                )
        else:
            Sounds.button_press()
            pause_menu = preload("res://ui/menu/pause_menu.tscn").instantiate()
            SceneManager.current_scene.add_child(pause_menu)
            change_state(E.GameState.PAUSED)

func end_game(success: bool = false):
    is_success = success
    PlayerService.freeze_player = true
    EnemiesService.stop_spawning()
    EnemiesService.kill_all()
    get_tree().create_timer(2.0).timeout.connect(func():
        change_state(E.GameState.GAME_OVER)
    )

func change_state(new_state: E.GameState):
    print("changing game state from [%s] to [%s]" % [E.to_str(E.GameState, state), E.to_str(E.GameState, new_state)])
    state = new_state
    state_changed.emit(new_state)
    if E.GameState.GAME_OVER == state:
        show_game_over()
    if is_inside_tree():
        if [E.GameState.PAUSED, E.GameState.CHOOSING_UPGRADE].has(state):
            get_tree().paused = true
        else:
            get_tree().paused = false

func increment_score(i: int) -> void:
    score += i
    emit_score_change()

func emit_score_change() -> void:
    MusicManager.update_music_intensity()
    score_changed.emit(score)

func show_game_over() -> void:
    var current_scene = SceneManager.current_scene
    if current_scene:
        var game_over_menu = preload("res://ui/menu/game_over_menu.tscn").instantiate()
        game_over_menu.is_success = is_success
        current_scene.add_child(game_over_menu)
