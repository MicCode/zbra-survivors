extends Node

enum ObjectType {
    PLAYER,
    ENNEMY,
    BOSS,
    COLLECTIBLE,
    GUN,
    XP
}

var tracked_objects: Dictionary = {} # key = object instance id, value = object infos (position, type..)

func track(object: Node2D, type: ObjectType):
    var object_id = object.get_instance_id()
    var texture: Texture = null
    if !tracked_objects.has(object_id):
        if [ObjectType.GUN, ObjectType.COLLECTIBLE].has(type) and object:
            var sprite = object.get_node("Sprite")
            if sprite and sprite is Sprite2D:
                texture = (sprite as Sprite2D).texture

        tracked_objects.set(object_id, MinimapTrackedObject.build(object.global_position, type, texture))
    else:
        push_warning("Object with id [%d] is already tracked by minimap" % object_id)

func moved(object: Node2D, new_position: Vector2):
    var object_id = object.get_instance_id()
    if !tracked_objects.has(object_id):
        push_warning("Tried to update position of untracked object with id [%d]" % object_id)
        return
    var tracking = tracked_objects.get(object_id) as MinimapTrackedObject
    tracking.position = new_position

func untrack(object: Node2D):
    var object_id = object.get_instance_id()
    if tracked_objects.has(object_id):
        tracked_objects.erase(object_id)
    else:
        push_warning("Object [%s] is not tracked by minimap, unable to untrack it" % str(object))

func clear():
    tracked_objects = {}
