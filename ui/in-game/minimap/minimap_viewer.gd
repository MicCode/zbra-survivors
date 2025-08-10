extends Control

const REFRESH_FPS = 25
const REFRESH_TIME = 1.0 / (REFRESH_FPS as float)

var map_size = Vector2(200, 150)
var map_scale_factor: float = 0.1
var map_opacity = 0.75
var map_zoom = Vector2(1.0, 1.0)

var known_objects_positions: Dictionary = {}
var refresh_timer: SceneTreeTimer

func _ready():
    modulate = Color(1, 1, 1, map_opacity)
    %MinimapCamera.zoom = map_zoom
    #size = map_size
    #position = Vector2(-map_size.x,0)
    #%SubViewportContainer.size = map_size
    #%SubViewport.size = map_size

func _process(_delta: float) -> void:
    if !refresh_timer:
        refresh_timer = get_tree().create_timer(REFRESH_TIME)
    elif refresh_timer.time_left > 0:
        return

    var tracked_objects = Minimap.tracked_objects
    for key in tracked_objects.keys():
        var obj = tracked_objects[key]
        if obj is MinimapTrackedObject:
            if !known_objects_positions.has(key):
                var marker = preload("res://ui/in-game/minimap/minimap_marker.tscn").instantiate()
                marker.position = obj.position * map_scale_factor
                marker.set_marker_type(obj.type)
                marker.set_texture(obj.sprite_texture)
                if obj.type == Minimap.ObjectType.GUN:
                    marker.rotation_degrees = -30.0
                %Miniworld.add_child(marker)
                known_objects_positions.set(key, { object_position = obj.position, marker_id = marker.get_instance_id()})
                if obj.type == Minimap.ObjectType.PLAYER:
                    move_camera_to(marker.position)
            else:
                var data = known_objects_positions.get(key)
                var last_known_position = data.object_position
                var marker_id = data.marker_id
                if last_known_position != obj.position:
                    var marker_instance = get_marker_by_instance_id(marker_id)
                    if marker_instance and marker_instance is Node2D:
                        marker_instance.position = obj.position * map_scale_factor
                        if obj.type == Minimap.ObjectType.PLAYER:
                            move_camera_to(marker_instance.position)
    clean_untracked()
    refresh_timer = get_tree().create_timer(REFRESH_TIME)

func clean_untracked():
    for object_id in known_objects_positions.keys():
        if !Minimap.tracked_objects.has(object_id):
            var marker = get_marker_by_instance_id(known_objects_positions.get(object_id).marker_id)
            known_objects_positions.erase(object_id)
            get_tree().create_tween().tween_property(marker, "modulate", Color.TRANSPARENT, 0.25).connect("finished", func():
                if marker:
                    marker.queue_free()
            )

func move_camera_to(target_position: Vector2):
    %MinimapCamera.global_position = target_position

func get_marker_by_instance_id(id: int) -> Node2D:
    for child in %Miniworld.get_children():
        if child.get_instance_id() == id:
            return child
    return null
