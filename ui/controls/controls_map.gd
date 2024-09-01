extends CanvasLayer

enum ControllerCombos {
	MOUSE_KEYBOARD,
	XBOX_CONTROLLER
}

var controls = {
	"Move": {
		ControllerCombos.MOUSE_KEYBOARD: ["Z", "Q", "S", "D"]
	},
	"Aim": {
		ControllerCombos.MOUSE_KEYBOARD: ["mouse"]
	},
	"Shoot": {
		ControllerCombos.MOUSE_KEYBOARD: ["mouse-LMB"]
	},
	"Equip": {
		ControllerCombos.MOUSE_KEYBOARD: ["E"]
	},
	"Dash": {
		ControllerCombos.MOUSE_KEYBOARD: ["SPACE"]
	},
	"Pause": {
		ControllerCombos.MOUSE_KEYBOARD: ["ESC"]
	}
}

var current_controller_combo = ControllerCombos.MOUSE_KEYBOARD

func _ready() -> void:
	for control in controls.keys():
		var control_label = Label.new()
		control_label.text = control
		control_label.modulate = Color(0, 0, 0)
		%GridContainer.add_child(control_label)
		var keys = controls[control][current_controller_combo]
		var keys_container = HBoxContainer.new()
		for key in keys:
			var icon = ControllerButtonIcon.new()
			icon.key_name = key
			icon.animate = true
			if key.contains(Enums.get_controller_name(Enums.Controllers.MOUSE)):
				icon.key_name = key
				icon.controller_name = Enums.get_controller_name(Enums.Controllers.MOUSE)
			else:
				if current_controller_combo == ControllerCombos.MOUSE_KEYBOARD:
					icon.key_name = Enums.get_controller_name(Enums.Controllers.KEYBOARD) + "-" + key
					icon.controller_name = Enums.get_controller_name(Enums.Controllers.KEYBOARD)
				elif current_controller_combo == ControllerCombos.XBOX_CONTROLLER:
					icon.key_name = Enums.get_controller_name(Enums.Controllers.XBOX) + "-" + key
					icon.controller_name = Enums.get_controller_name(Enums.Controllers.XBOX)

			keys_container.add_child(icon)

		%GridContainer.add_child(keys_container)
