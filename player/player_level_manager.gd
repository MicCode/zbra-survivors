extends Node
signal menu_displayed_changed(displayed: bool)

const MENU_OPENING_DELAY = 0.8
var n_menu_to_display: int = 0

func _ready() -> void:
    n_menu_to_display = 0
    %Timer.timeout.connect(func():
        if n_menu_to_display > 0:
            _show_lvl_up_menu(n_menu_to_display)
    )

func register_lvl_up(number_of_gained_levels: int):
    if number_of_gained_levels > 0 and n_menu_to_display == 0:
        # as we want to notify only once, the first time we knwow a new level will be gained
        PlayerService.notify_level_gain.emit()

    n_menu_to_display += number_of_gained_levels
    if %Timer.is_stopped():
        %Timer.start(MENU_OPENING_DELAY)

func _show_lvl_up_menu(n_times: int):
    #print("Must show lvl_up menu %d times" % n_times)
    var lvl_up_menu = preload("res://ui/menu/lvl_up/lvl_up_menu.tscn").instantiate()
    lvl_up_menu.set_remaining_times(n_times)
    n_times -= 1
    SceneManager.current_scene.add_child(lvl_up_menu)
    lvl_up_menu.picked_modifier.connect(func(mod: Mod):
        ModsService.register_new_modifier(mod)
        lvl_up_menu.slide_out().finished.connect(func():
            lvl_up_menu.queue_free()
            if n_times <= 0:
                menu_displayed_changed.emit(false)
                GameService.change_state(E.GameState.RUNNING)
                n_menu_to_display = 0
            else:
                _show_lvl_up_menu(n_times)
        )
    )
    GameService.change_state(E.GameState.CHOOSING_UPGRADE)
    menu_displayed_changed.emit(true)
