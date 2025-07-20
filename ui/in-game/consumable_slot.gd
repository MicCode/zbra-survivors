extends PanelContainer

func _ready() -> void:
    GameService.consumable_changed.connect(_update_slot)
    _update_slot(GameService.consumable)

func _update_slot(new_consumable: ConsumableItem):
    # print("New consumable : " + str(new_consumable))
    if new_consumable == null:
        %ConsumableSprite.texture = null
        %ConsumableButton.hide()
        return

    var consumable_sprite = new_consumable.get_node("Sprite") as Sprite2D
    if !consumable_sprite:
        push_error("Consumable [%s] has no [Sprite] node, unable to load its texture" % str(new_consumable))
        return
    %ConsumableSprite.texture = consumable_sprite.texture
    %ConsumableButton.show()
    # TODO display the use number
