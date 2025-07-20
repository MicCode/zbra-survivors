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

func get_random_from_folder(folder_path: String) -> String:
    # print("Getting files in folder [%s]" % folder_path)
    var dir = DirAccess.open(folder_path)
    if dir == null:
        push_error("Cannot find folder %s" % folder_path)
        return ""

    var files := []

    dir.list_dir_begin()
    var file_name = dir.get_next()
    while file_name != "":
        # print(" - file: [%s]" % file_name)
        if not dir.current_is_dir() and not file_name.ends_with(".import"):
            files.append(file_name)
        file_name = dir.get_next()
    dir.list_dir_end()

    if files.is_empty():
        push_error("No file found in folder %s" % folder_path)
        return ""

    # print("Found %d files" % files.size())

    var random_index = randi() % files.size()
    var file_path = folder_path + "/" + files[random_index]
    # print("Picked file [%s]" % file_path)
    return file_path
