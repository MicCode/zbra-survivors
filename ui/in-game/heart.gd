extends Panel
class_name HeartUI

var state: Enums.HeartStates = Enums.HeartStates.Full

func change_state(new_state: Enums.HeartStates):
    state = new_state
    # TODO display a nice animation effect ?
    match state:
        Enums.HeartStates.Full:
            %FullTexture.show()
            %EmptyTexture.hide()
        Enums.HeartStates.Empty:
            %FullTexture.hide()
            %EmptyTexture.show()
