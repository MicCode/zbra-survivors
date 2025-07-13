extends StaticBody2D
class_name CollectibleItem

func _ready() -> void:
    Minimap.track(self, Minimap.ObjectType.COLLECTIBLE)

func _exit_tree() -> void:
    Minimap.untrack(self)
