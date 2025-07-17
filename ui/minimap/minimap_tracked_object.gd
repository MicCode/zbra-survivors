extends Resource
class_name MinimapTrackedObject

var position: Vector2
var type: Minimap.ObjectType
var sprite_texture: Texture

static func build(_position: Vector2, _type: Minimap.ObjectType, _sprite_texture: Texture = null) -> MinimapTrackedObject:
    var instance = MinimapTrackedObject.new()
    instance.position = _position
    instance.type = _type
    instance.sprite_texture = _sprite_texture
    return instance
