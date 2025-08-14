extends Panel
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
const TEXTURE_SIZE = 16

var state: DashGaugeStates = DashGaugeStates.FULL

func _ready() -> void:
    PlayerService.player_state_changed.connect(_update_gauge)

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
        update_texture()

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

func update_texture():
    var texture = %Texture.texture
    if texture is AtlasTexture:
        match state:
            DashGaugeStates.EMPTY: texture.region = move_in_atlas(0, 0)
            DashGaugeStates.LOADING_1: texture.region = move_in_atlas(1, 0)
            DashGaugeStates.LOADING_2: texture.region = move_in_atlas(2, 0)
            DashGaugeStates.LOADING_3: texture.region = move_in_atlas(0, 1)
            DashGaugeStates.LOADING_4: texture.region = move_in_atlas(1, 1)
            DashGaugeStates.USING: texture.region = move_in_atlas(2, 1)
            DashGaugeStates.FULL: texture.region = move_in_atlas(0, 2)

func move_in_atlas(x: int, y: int) -> Rect2:
    return Rect2(x * TEXTURE_SIZE, y * TEXTURE_SIZE, TEXTURE_SIZE, TEXTURE_SIZE)
