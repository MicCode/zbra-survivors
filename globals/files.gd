extends Node

const SETTINGS_JSON_FILE = "user://settings.json"


func read_settings() -> Dictionary:
    return _read_file(SETTINGS_JSON_FILE)

func write_settings(data: Dictionary):
    _write_file(SETTINGS_JSON_FILE, data)


func _read_file(file_path: String, as_array: bool = false):
    var file = FileAccess.open(file_path, FileAccess.READ)
    if file:
        var json_content = file.get_as_text()
        file.close()
        var json := JSON.new()
        var error := json.parse(json_content)
        if error == OK:
            return json.data
        else:
            push_error("Unable to read data from file [" + file_path + "], got data: " + json_content)
    else:
        push_error("Unable to read data from file [" + file_path + "]")

    if as_array:
        return []
    else:
        return {}

func _write_file(file_path: String, data):
    var file = FileAccess.open(file_path, FileAccess.WRITE)
    if file:
        var json_content = JSON.stringify(data, "\t")
        file.store_string(json_content)
        file.close()
    else:
        push_error("Unable to write data in file [" + file_path + "]")
