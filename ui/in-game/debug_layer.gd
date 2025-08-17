extends CanvasLayer

@export var debug_mode: bool = false

func _ready() -> void:
    ModsService.active_mods_changed.connect(update_mods)
    update_mods()

func _process(_delta: float) -> void:
    %FPS.text = str("FPS: %.1f" % Engine.get_frames_per_second())
    %Timescale.text = str("Timescale: %.1f" % Engine.time_scale)

    %Music.text = str("Music: %s" % MusicManager.music(MusicManager.current_music))
    %MusicLayer.text = str("MusicLayer: %s" % E.to_str(E.MusicLayer, MusicManager.current_layer))

    %MasterVolume.text = str("Master volume: %.1f" % SoundPlayer.get_bus_volume_linear(SoundPlayer.Bus.MASTER))
    %MusicVolume.text = str("Music volume: %.1f" % SoundPlayer.get_bus_volume_linear(SoundPlayer.Bus.MUSIC))
    %SFXVolume.text = str("SFX volume: %.1f" % SoundPlayer.get_bus_volume_linear(SoundPlayer.Bus.SFX))
    %EffectsVolume.text = str("Effects volume: %.1f" % SoundPlayer.get_bus_volume_linear(SoundPlayer.Bus.EFFECTS))
    %AnnouncesVolume.text = str("Announcements volume: %.1f" % SoundPlayer.get_bus_volume_linear(SoundPlayer.Bus.ANNOUNCEMENTS))

    %PlayingSFX.text = str("Playing SFX: %d" % SoundPlayer.sfx_players.size())
    %SFXCache.text = str("Cached SFX: %d" % SoundPlayer.sfx_cache.size())
    %PlayingEffects.text = str("Playing Effects: %d" % SoundPlayer.effects_players.size())
    %EffectsCache.text = str("Cached Effects: %d" % SoundPlayer.effects_cache.size())

    %AnnouncerCounter.text = str("Announcer cpt: %d" % Announcer.kill_in_one_shot)


func update_mods():
    for child in %Mods.get_children():
        child.queue_free()

    for mod in ModsService.active_mods:
        var label = Label.new()
        if mod.value >= 0:
            label.text = "+"
        label.text += str("%d" % mod.value)
        if !mod.is_absolute:
            label.text += "%"
        label.text += " " + E.to_str(E.ModName, mod.name)
        %Mods.add_child(label)
