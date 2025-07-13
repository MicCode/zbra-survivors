extends Resource
class_name MinimapTrackedObject

var position: Vector2
var type: Minimap.ObjectType

static func build(_position: Vector2, _type: Minimap.ObjectType) -> MinimapTrackedObject:
    var instance = MinimapTrackedObject.new()
    instance.position = _position
    instance.type = _type
    return instance
