extends EditorPlugin

var inspector_plugin: ControllerButtonIconInspectorPlugin

func _enter_tree():
    inspector_plugin = ControllerButtonIconInspectorPlugin.new()
    add_inspector_plugin(inspector_plugin)

func _exit_tree():
    remove_inspector_plugin(inspector_plugin)


class ControllerButtonIconInspectorPlugin extends EditorInspectorPlugin:
    func _can_handle(object):
        return object is ControllerButtonIcon

    func _parse_property(object, type, path, hint, hint_text, usage, wide):
        if path == "action":
            var editor = ControllerButtonIconEditor.new()
            editor.set_value(object.get(path))
            add_property_editor(path, editor)
            return true
        return false