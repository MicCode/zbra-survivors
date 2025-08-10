extends Node

const DEBUG_MODE = false
const MUSICS_FOLDER = "res://assets/musics"
const LAYER_TRANSITION_DURATION: float = 0.25
const MUSIC_TRANSITION_DURATION: float = 1.0
const MAX_VOLUME_LINEAR: float = 0.9

#region enums ---------------------------------------------------------------------------------------
enum Music {
    NOT_SET,
    ELECTRO_1,
    ELECTRO_2,
    EPIC_1,
    EPIC_2,
    METAL_1,
    METAL_2,

    ## Used to load simple musics that are not layered, see function `set_non_layered_music()`
    NON_LAYERED,
}
## Util function to display Music enum member as a string
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
## Util function to display MusicLayer enum member as a string
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
#endregion

#region variables ---------------------------------------------------------------------------------------
var players: Dictionary = {
    MusicLayer.MUFFLED: _init_player(),
    MusicLayer.SOFT: _init_player(),
    MusicLayer.MEDIUM: _init_player(),
    MusicLayer.HARD: _init_player(),
}

var current_music: Music
var next_music: Music
var next_non_layered_music_filename: String

var current_layer: MusicLayer
var next_layer: MusicLayer

var current_player: AudioStreamPlayer
var previous_player: AudioStreamPlayer
var crossfade_value := 0.0

var can_change_layer = true
#endregion

#region control
func play():
    if DEBUG_MODE: print("Playing music")
    for player in players.values():
        player.play()

func stop():
    if DEBUG_MODE: print("Stopping music")
    for player in players.values():
        player.stop()
#endregion

#region layer change ---------------------------------------------------------------------------------------
func set_layer(new_layer: MusicLayer) -> bool:
    if !can_change_layer:
        return false
    next_layer = new_layer
    return true

func _change_layer(new_layer: MusicLayer):
    if new_layer != current_layer:
        var previous_layer = current_layer
        current_layer = new_layer
        if DEBUG_MODE: print("Changing music layer from [%s] to [%s]" % [music_layer(previous_layer), music_layer(current_layer)])

        previous_player = players.get(previous_layer)
        current_player = players.get(current_layer)
        for player in players.values():
            if ![previous_layer, current_player].has(player):
                player.volume_db = -80.0

        crossfade_value = 0.0
        create_tween().tween_property(self, "crossfade_value", MAX_VOLUME_LINEAR, LAYER_TRANSITION_DURATION).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
#endregion

#region music change ---------------------------------------------------------------------------------------
## Set a new layered music to be played with smooth crossfade from previously played music
func set_music(new_music: Music):
    next_music = new_music

## Set a new non layered music to be played with smooth crossfade from previously played music,
## this music will not have layered music features (changing intensity with layers) and must be the music filename, including extendion (without folder path)
func set_non_layered_music(new_music_path: String):
    next_music = Music.NON_LAYERED
    next_non_layered_music_filename = new_music_path


func _change_music(new_music: Music):
    var specific_folder = ""
    if new_music != Music.NON_LAYERED:
        specific_folder = music(new_music)
    var folder_path = "/".join([MUSICS_FOLDER, specific_folder])
    var dir = DirAccess.open(folder_path)
    if dir == null:
        push_error("Cannot find music folder %s" % folder_path)
        return

    if !current_music or new_music != current_music:
        var music_filename = next_non_layered_music_filename
        if new_music != Music.NON_LAYERED:
            music_filename = music(new_music)
        if DEBUG_MODE: print("Changing music from [%s] to [%s]" % [music(current_music), music_filename])
        current_music = new_music
        previous_player = current_player

        var tmp_players: Dictionary = {
            MusicLayer.MUFFLED: _init_player(),
            MusicLayer.SOFT: _init_player(),
            MusicLayer.MEDIUM: _init_player(),
            MusicLayer.HARD: _init_player(),
        }
        if new_music == Music.NON_LAYERED:
            var stream = _load_stream(folder_path + "/" + next_non_layered_music_filename)
            tmp_players.get(MusicLayer.MUFFLED).stream = stream
            tmp_players.get(MusicLayer.SOFT).stream = stream
            tmp_players.get(MusicLayer.MEDIUM).stream = stream
            tmp_players.get(MusicLayer.HARD).stream = stream
        else:
            tmp_players.get(MusicLayer.MUFFLED).stream = _load_stream(folder_path + "/muffled.ogg")
            tmp_players.get(MusicLayer.SOFT).stream = _load_stream(folder_path + "/soft.ogg")
            tmp_players.get(MusicLayer.MEDIUM).stream = _load_stream(folder_path + "/medium.ogg")
            tmp_players.get(MusicLayer.HARD).stream = _load_stream(folder_path + "/hard.ogg")

        for player in tmp_players.values():
            add_child(player)
            player.play()

        current_player = tmp_players.get(current_layer)

        can_change_layer = false
        crossfade_value = 0.0
        create_tween().tween_property(self, "crossfade_value", MAX_VOLUME_LINEAR, MUSIC_TRANSITION_DURATION).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT).finished.connect(func():
            for layer in tmp_players.keys():
                players.get(layer).queue_free()
                players.set(layer, tmp_players.get(layer))

            can_change_layer = true
        )
#endregion

#region internal ---------------------------------------------------------------------------------------
func _init() -> void:
    process_mode = Node.PROCESS_MODE_ALWAYS
    for player in players.values():
        add_child(player)

    next_layer = MusicLayer.MUFFLED
    set_layer(MusicLayer.MUFFLED)

func _process(_delta):
    if get_tree().paused and current_layer != MusicLayer.MUFFLED:
        _change_layer(MusicLayer.MUFFLED)
    elif !get_tree().paused and current_layer != next_layer:
        _change_layer(next_layer)

    if next_music != current_music:
        _change_music(next_music)

    _apply_crossfade()

func _apply_crossfade():
    var vol_a := to_linear(0.0) * (MAX_VOLUME_LINEAR - crossfade_value)
    var vol_b := to_linear(0.0) * crossfade_value

    if previous_player:
        previous_player.volume_db = linear_to_db(vol_a)
    if current_player:
        current_player.volume_db = linear_to_db(vol_b)

func _init_player() -> AudioStreamPlayer:
    var new_player = AudioStreamPlayer.new()
    new_player.bus = SoundPlayer.bus(SoundPlayer.Bus.MUSIC)
    new_player.volume_db = to_db(0.0)
    new_player.finished.connect(func(): new_player.play())
    return new_player

func _load_stream(file_path: String) -> AudioStream:
    var stream = load(file_path)
    if stream is AudioStream:
        return stream
    push_error("Music file not found: " + file_path)
    return null
#endregion

#region utils ---------------------------------------------------------------------------------------
func get_player_volume_linear(layer: MusicLayer) -> float:
    return to_linear(players.get(layer).volume_db)

## Converts a linear float value (between 0.0 and 1.0) into a DB value (logarithmic)
func to_db(linear: float) -> float:
    if linear < 0.0001:
        return -80.0
    return clamp(20.0 * log(linear) / log(10.0), -80.0, 0.0)

## Converts a DB value (logarithmic) into a linear float value (between 0.0 and 1.0)
func to_linear(db: float) -> float:
    return clamp(pow(10.0, db / 20.0), 0.0, 1.0)
#endregion
