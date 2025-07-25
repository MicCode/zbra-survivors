extends StaticBody2D
class_name ConsumableItem

@export var stats: ConsumableItemStats
var time_used: int = 0
var can_be_used = true

func _ready() -> void:
    if !stats:
        push_error("Consumable item has no stats defined")
        return

    Minimap.track(self, Minimap.ObjectType.COLLECTIBLE)
    get_tree().create_timer(stats.show_time).connect("timeout", _on_show_time_timeout)

func _exit_tree() -> void:
    Minimap.untrack(self)

func _on_show_time_timeout():
    get_tree().create_tween().tween_property(self, "modulate", Color.TRANSPARENT, 0.25).connect("finished", func():
        queue_free()
    )

func increment_use():
    time_used += 1
    can_be_used = false
    SceneManager.current_scene.get_tree().create_timer(stats.time_between_use).connect("timeout", func(): can_be_used = true)


func _on_area_2d_body_entered(body: Node2D) -> void:
    if body is not Player or !%ButtonIcon:
        return
    if self is GunCollectible or (GameService.consumable and stats and !stats.immediate_use):
        %ButtonIcon.show()
    else:
        %ButtonIcon.hide()


func _on_area_2d_body_exited(body: Node2D) -> void:
    if body is not Player or !%ButtonIcon:
        return
    %ButtonIcon.hide()
