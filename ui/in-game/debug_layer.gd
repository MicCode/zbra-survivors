extends CanvasLayer

@export var debug_mode: bool = false

func _ready() -> void:
    GameState.stats_modifiers_changed.connect(update_mods)
    update_mods()

func _process(_delta: float) -> void:
    %FPS.text = str("FPS: %.1f" % Engine.get_frames_per_second())
    %Timescale.text = str("Timescale: %.1f" % Engine.time_scale)
    %Music.text = str("Music: %s" % MusicManager.music(MusicManager.current_music))
    %MusicLayer.text = str("MusicLayer: %s" % MusicManager.music_layer(MusicManager.current_layer))
    %PlayingSFX.text = str("Playing SFX: %d" % SoundPlayer.sfx_players.size())
    %SFXCache.text = str("Cached SFX: %d" % SoundPlayer.sfx_cache.size())
    %PlayingEffects.text = str("Playing Effects: %d" % SoundPlayer.effects_players.size())
    %EffectsCache.text = str("Cached Effects: %d" % SoundPlayer.effects_cache.size())
    %AnnouncerCounter.text = str("Announcer cpt: %d" % Announcer.kill_in_one_shot)


func update_mods():
    for child in %Mods.get_children():
        child.queue_free()

    for mod in GameState.stats_modifiers:
        var label = Label.new()
        if mod.modifier_value >= 0:
            label.text = "+"
        label.text += str("%d" % mod.modifier_value)
        if !mod.is_absolute:
            label.text += "%"
        label.text += " " + Modifiers.get_name_label(mod.modifier)
        %Mods.add_child(label)
