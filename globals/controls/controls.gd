extends Node

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

enum PlayerAction {
    DASH,
    GRAB,
    SHOOT,
    USE,
}

enum JoypadButtons {
    A,
    B,
    X,
    Y,
    RB,
    RT,
    LB,
    LT,
    LEFT_STICK,
    RIGHT_STICK,
    START,
    BACK,
    DPAD_UP,
    DPAD_RIGHT,
    DPAD_DOWN,
    DPAD_LEFT
}
func get_joypad_control(button: JoypadButtons) -> InputControl:
    match button:
        JoypadButtons.A:
            return InputControl.with("xbox", "A")
        JoypadButtons.B:
            return InputControl.with("xbox", "B")
        JoypadButtons.X:
            return InputControl.with("xbox", "X")
        JoypadButtons.Y:
            return InputControl.with("xbox", "Y")
        JoypadButtons.RB:
            return InputControl.with("xbox", "RB")
        JoypadButtons.RT:
            return InputControl.with("xbox", "RT")
        JoypadButtons.LB:
            return InputControl.with("xbox", "LB")
        JoypadButtons.LT:
            return InputControl.with("xbox", "LT")
        JoypadButtons.LEFT_STICK:
            return InputControl.with("xbox", "joystick-L")
        JoypadButtons.RIGHT_STICK:
            return InputControl.with("xbox", "joystick-R")
        JoypadButtons.START:
            return InputControl.with("xbox", "START") # TODO sprites to be created
        JoypadButtons.BACK:
            return InputControl.with("xbox", "BACK") # TODO sprites to be created
        JoypadButtons.DPAD_UP:
            return InputControl.with("xbox", "DPAD_UP") # TODO sprites to be created
        JoypadButtons.DPAD_RIGHT:
            return InputControl.with("xbox", "DPAD_RIGHT") # TODO sprites to be created
        JoypadButtons.DPAD_DOWN:
            return InputControl.with("xbox", "DPAD_DOWN") # TODO sprites to be created
        JoypadButtons.DPAD_LEFT:
            return InputControl.with("xbox", "DPAD_LEFT") # TODO sprites to be created
        _:
            push_error("No input control defined for joypad button [%d]" % button)
            return null


enum KeyboardButtons {
    A,
    D,
    E,
    F,
    I,
    Q,
    R,
    S,
    W,
    Z,
    ESC,
    SPACE,
}
func get_keyboard_control(button: KeyboardButtons) -> InputControl:
    match button:
        KeyboardButtons.A:
            return InputControl.with("keyboard", "A")
        KeyboardButtons.D:
            return InputControl.with("keyboard", "D")
        KeyboardButtons.E:
            return InputControl.with("keyboard", "E")
        KeyboardButtons.F:
            return InputControl.with("keyboard", "F")
        KeyboardButtons.I:
            return InputControl.with("keyboard", "I")
        KeyboardButtons.Q:
            return InputControl.with("keyboard", "Q")
        KeyboardButtons.R:
            return InputControl.with("keyboard", "R")
        KeyboardButtons.S:
            return InputControl.with("keyboard", "S")
        KeyboardButtons.W:
            return InputControl.with("keyboard", "W")
        KeyboardButtons.Z:
            return InputControl.with("keyboard", "Z")
        KeyboardButtons.ESC:
            return InputControl.with("keyboard", "ESC")
        KeyboardButtons.SPACE:
            return InputControl.with("keyboard", "SPACE")
        _:
            push_error("No input control defined for keyboard button [%d]" % button)
            return null


enum MouseButtons {
    LEFT,
    RIGHT,
    MIDDLE,
}
func get_mouse_control(button: MouseButtons) -> InputControl:
    match button:
        MouseButtons.LEFT:
            return InputControl.with("mouse", "LMB")
        MouseButtons.RIGHT:
            return InputControl.with("mouse", "RMB")
        MouseButtons.MIDDLE:
            return InputControl.with("mouse", "MMB")
        _:
            push_error("No input control defined for mouse button [%d]" % button)
            return null


func get_input_control(action: PlayerAction) -> InputControl:
    var is_joypad = is_joypad_connected()
    match action:
        PlayerAction.DASH:
            if is_joypad:
                return get_joypad_control(JoypadButtons.LT)
            else:
                return get_keyboard_control(KeyboardButtons.SPACE)
        PlayerAction.SHOOT:
            if is_joypad:
                return get_joypad_control(JoypadButtons.RT)
            else:
                return get_mouse_control(MouseButtons.LEFT)
        PlayerAction.GRAB:
            if is_joypad:
                return get_joypad_control(JoypadButtons.X)
            else:
                return get_keyboard_control(KeyboardButtons.E)
        PlayerAction.USE:
            if is_joypad:
                return get_joypad_control(JoypadButtons.RB)
            else:
                return get_mouse_control(MouseButtons.RIGHT)
        _:
            push_error("Unknown player action [%d]" % action)
            return null


func is_pressed(action: PlayerAction) -> bool:
    var action_name = null
    match action:
        PlayerAction.DASH:
            action_name = "dash"
        PlayerAction.GRAB:
            action_name = "grab"
        PlayerAction.SHOOT:
            action_name = "shoot"
        PlayerAction.USE:
            action_name = "use"
        _:
            push_error("Unsupported action [%d]" % action)
            return false
    var pressed = Input.is_action_pressed(action_name)
    #print("Checking action [%s]: %s" % [action_name, str(pressed)])
    return pressed

func is_joypad_connected() -> bool:
    # TODO we should rather check from where was the last input sent and switch between joypad/keyboard+mouse automatically
    # TODO add a game setting for that ?
    var joypads = Input.get_connected_joypads()
    return joypads.size() > 0

func vibrate(duration: float, weak: float = 0.1, strong: float = 1.0):
    if !Settings.game_settings.enable_vibrations or !is_joypad_connected():
        return
    Input.start_joy_vibration(0, weak, strong, duration)
