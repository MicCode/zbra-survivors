extends Node

# TODO set a music loop config (to tell if we play the same music when it ends, or if we randomly choose another
# TODO add a smooth transition between musics
# TODO allow non-layered music to be played (music is played but layer changes do not have effect)
# TODO allow user to define preferred music style and chose musics accordingly ?

enum Music {
    NOT_SET,
    ELECTRO_1,
    ELECTRO_2,
    EPIC_1,
    EPIC_2,
    METAL_1,
    METAL_2
}
func music(_music: Music) -> String:
    match _music:
        Music.NOT_SET: return "not-set"
        Music.ELECTRO_1: return "electro-1"
        Music.ELECTRO_2: return "electro-2"
        Music.EPIC_1: return "epic-1"
        Music.EPIC_2: return "epic-2"
        Music.METAL_1: return "metal-1"
        Music.METAL_2: return "metal-2"
        _:
            push_error("Unknown Music [%d]" % _music)
            return "???"

enum MusicLayer {
    NOT_SET,
    MUFFLED,
    SOFT,
    MEDIUM,
    HARD
}
func music_layer(_layer: MusicLayer) -> String:
    match _layer:
        MusicLayer.NOT_SET: return "NOT_SET"
        MusicLayer.MUFFLED: return "MUFFLED"
        MusicLayer.SOFT: return "SOFT"
        MusicLayer.MEDIUM: return "MEDIUM"
        MusicLayer.HARD: return "HARD"
        _:
            push_error("Unknown MusicLayer [%d]" % _layer)
            return "???"

const MUSICS_FOLDER = "res://assets/musics"
const TRANSITION_DURATION: float = 0.25
const MUSIC_VOLUME_OFFSET: float = 0.9

var muffled_player: AudioStreamPlayer
var soft_player: AudioStreamPlayer
var medium_player: AudioStreamPlayer
var hard_player: AudioStreamPlayer

var currently_playing_music: Music
var currently_playing_layer: MusicLayer
var wanted_layer: MusicLayer

var crossfade_value := 0.0
var current_player: AudioStreamPlayer
var previous_player: AudioStreamPlayer
var tween: Tween

func _init() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    muffled_player = init_layer()
    add_child(muffled_player)
    soft_player = init_layer()
    add_child(soft_player)
    medium_player = init_layer()
    add_child(medium_player)
    hard_player = init_layer()
    add_child(hard_player)
    wanted_layer = MusicLayer.MUFFLED
    change_layer(MusicLayer.MUFFLED)

func _process(_delta):
    if get_tree().paused and currently_playing_layer != MusicLayer.MUFFLED:
        _change_layer(MusicLayer.MUFFLED)
    elif !get_tree().paused and currently_playing_layer != wanted_layer:
        _change_layer(wanted_layer)

    _apply_crossfade()

func _apply_crossfade():
    var vol_a := to_linear(0.0) * (MUSIC_VOLUME_OFFSET - crossfade_value)
    var vol_b := to_linear(0.0) * crossfade_value

    if previous_player:
        previous_player.volume_db = linear_to_db(vol_a)
    if current_player:
        current_player.volume_db = linear_to_db(vol_b)

func init_layer() -> AudioStreamPlayer:
    var new_player = AudioStreamPlayer.new()
    new_player.bus = &"Music"
    new_player.volume_db = to_db(0.0)
    new_player.finished.connect(func(): new_player.play())
    return new_player

func change_layer(layer: MusicLayer):
    wanted_layer = layer

func _change_layer(layer: MusicLayer):
    if layer != currently_playing_layer:
        var previous_layer = currently_playing_layer
        currently_playing_layer = layer
        print("Changing music layer from [%s] to [%s]" % [music_layer(previous_layer), music_layer(currently_playing_layer)])

        match previous_layer:
            MusicLayer.MUFFLED: previous_player = muffled_player
            MusicLayer.SOFT: previous_player = soft_player
            MusicLayer.MEDIUM: previous_player = medium_player
            MusicLayer.HARD: previous_player = hard_player

        match currently_playing_layer:
            MusicLayer.MUFFLED: current_player = muffled_player
            MusicLayer.SOFT: current_player = soft_player
            MusicLayer.MEDIUM: current_player = medium_player
            MusicLayer.HARD: current_player = hard_player

        if ![previous_layer, current_player].has(muffled_player):
            muffled_player.volume_db = -80.0
        if ![previous_layer, current_player].has(soft_player):
            soft_player.volume_db = -80.0
        if ![previous_layer, current_player].has(medium_player):
            medium_player.volume_db = -80.0
        if ![previous_layer, current_player].has(hard_player):
            hard_player.volume_db = -80.0

        crossfade_value = 0.0
        create_tween().tween_property(self, "crossfade_value", MUSIC_VOLUME_OFFSET, TRANSITION_DURATION).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)

func play():
    print("Playing music [%s]" % music(currently_playing_music))
    muffled_player.play()
    soft_player.play()
    medium_player.play()
    hard_player.play()

func stop():
    muffled_player.stop()
    soft_player.stop()
    medium_player.stop()
    hard_player.stop()

func change_music(_music: Music):
    var folder_path = "%s/%s" % [MUSICS_FOLDER, music(_music)]
    var dir = DirAccess.open(folder_path)
    if dir == null:
        push_error("Cannot find music folder %s" % folder_path)
        return

    if !currently_playing_music or _music != currently_playing_music:
        currently_playing_music = _music
        # TODO add transition if a music is already playing

        muffled_player.stream = _load_stream(folder_path + "/muffled.ogg")
        soft_player.stream = _load_stream(folder_path + "/soft.ogg")
        medium_player.stream = _load_stream(folder_path + "/medium.ogg")
        hard_player.stream = _load_stream(folder_path + "/hard.ogg")

        play()

func _load_stream(file_path: String) -> AudioStream:
    var stream = load(file_path)
    if stream is AudioStream:
        return stream
    push_error("Music file not found: " + file_path)
    return null

func to_db(linear: float) -> float:
    if linear < 0.0001:
        return -80.0
    return clamp(20.0 * log(linear) / log(10.0), -80.0, 0.0)

func to_linear(db: float) -> float:
    return clamp(pow(10.0, db / 20.0), 0.0, 1.0)
