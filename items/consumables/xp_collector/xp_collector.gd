extends ConsumableItem
class_name XpCollector

const MOVE_SPEED: float = 1000.0

var chase_player = false

func _ready() -> void:
    _rotate()
    %AnimationPlayer.active = false
    super._ready()

func _physics_process(delta: float) -> void:
    if chase_player and GameState.player_instance:
        move_to(GameState.player_instance)

func _rotate():
    %Sprite.rotation_degrees = 0
    get_tree().create_tween().tween_property(%Sprite, "rotation_degrees", 360, 1.0).connect("finished", _rotate)

func move_to_player():
    chase_player = true

func move_to(other_node: Node2D):
    var other_position = other_node.global_position
    var direction_to_other = global_position.direction_to(other_position)
    velocity = direction_to_other * MOVE_SPEED
    move_and_slide()
    Minimap.moved(self, global_position)
