extends StaticBody2D
class_name ConsumableItem

@export var stats: ConsumableItemStats

func _ready() -> void:
    Minimap.track(self, Minimap.ObjectType.COLLECTIBLE)
    get_tree().create_timer(stats.show_time).connect("timeout", _on_show_time_timeout)

func _exit_tree() -> void:
    Minimap.untrack(self)

func _on_show_time_timeout():
    get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.25).connect("finished", func():
        queue_free()
    )
