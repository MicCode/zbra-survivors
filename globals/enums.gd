extends Node

enum Orientations {
    LEFT,
    RIGHT,
    BELOW,
    ABOVE,
}

enum Controllers {
    MOUSE,
    KEYBOARD,
    XBOX
}

func get_controller_name(controller: Controllers) -> String:
    match controller:
        Controllers.MOUSE: return "mouse"
        Controllers.KEYBOARD: return "keyboard"
        Controllers.XBOX: return "xbox"
        _: return "unknown controller"
