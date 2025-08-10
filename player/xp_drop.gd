extends CharacterBody2D
class_name XpDrop

const MOVE_SPEED: float = 1000.0
const MERGE_DISTANCE: float = 10.0

var chase_player = false
var is_being_merged = false
@export var xp_value: float = 1.0

func with_value(_value: float) -> XpDrop:
    xp_value = _value
    return self

func _ready() -> void:
    Minimap.track(self, Minimap.ObjectType.XP)

func _physics_process(_delta: float) -> void:
    if is_being_merged:
        # if this is set to true, it means this XpDrop is being absorbed (merged) by another XpDrop
        # and shouldnt process physics anymore, before its effective destruction, to avoid both merged drop destruction
        return

    if chase_player and GameState.player_instance:
        move_to(GameState.player_instance)
        if get_distance(GameState.player_instance.global_position) < MERGE_DISTANCE:
            GameState.gain_xp(xp_value)
            Sounds.coin()
            queue_free()
    else:
        var other_xp_drop_in_range: Array = %FusionZone.get_overlapping_bodies().filter(func(o: Node2D): return o is XpDrop and o != self)
        if !other_xp_drop_in_range.is_empty():
            var closest_xp_drop: XpDrop = null
            for xp_drop in other_xp_drop_in_range:
                if !closest_xp_drop or get_distance(xp_drop.global_position) < get_distance(closest_xp_drop.global_position):
                    closest_xp_drop = xp_drop
            move_to(closest_xp_drop)
            if get_distance(closest_xp_drop.global_position) < MERGE_DISTANCE:
                xp_value += closest_xp_drop.xp_value
                closest_xp_drop.is_being_merged = true
                closest_xp_drop.queue_free()

func get_distance(other_position: Vector2) -> float:
    return abs((global_position - other_position).length())

func move_to(other_node: Node2D):
    var other_position = other_node.global_position
    var direction_to_other = global_position.direction_to(other_position)
    velocity = direction_to_other * MOVE_SPEED
    move_and_slide()
    Minimap.moved(self, global_position)

func _exit_tree() -> void:
    Minimap.untrack(self)

func move_to_player():
    chase_player = true
