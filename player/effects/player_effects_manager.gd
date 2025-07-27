extends Node2D
class_name PlayerEffectsManager

signal effect_finished(effect: PlayerEffect.Effects)

func add_effect(_effect: PlayerEffect.Effects, _duration: float) -> PlayerEffect:
    # TODO remove previous effect if new effect is of same type of an existing one (or extend its duration ?)
    var player_effect = PlayerEffect.new()
    player_effect.duration = _duration
    player_effect.effect = _effect
    self.add_child(player_effect)
    player_effect.finished.connect(func():
        effect_finished.emit(player_effect.effect)
    )
    return player_effect

func has_effect(effect: PlayerEffect.Effects) -> bool:
    return get_children().any(func(e: PlayerEffect) -> bool:
        return e.effect == effect
    )
