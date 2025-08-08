extends Node2D

var visual_effects: Dictionary = {}

func start_effect(effect_name: String, effect: PackedScene, position_override = Vector2(0, 0)):
    if !visual_effects.has(effect_name):
        var instance = effect.instantiate() as Node2D
        instance.position = position_override
        visual_effects.set(effect_name, instance)
        add_child(instance)
        if instance.has_method("fade_in"):
           instance.fade_in()

func stop_effect(effect_name: String):
    if visual_effects.has(effect_name):
        var instance = visual_effects.get(effect_name)
        if instance.has_method("fade_out"):
            instance.fade_out().connect("finished", func():
                instance.queue_free()
                visual_effects.erase(effect_name)
            )
        else:
            remove_child(instance)
            visual_effects.erase(effect_name)


func stop_all():
    for effect_name in visual_effects.keys():
        stop_effect(effect_name)
