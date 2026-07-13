extends HBoxContainer

var Keybind : InputEvent
var Event := ""
var ShowCtrl := true

func _ready() -> void:
	if ShowCtrl:
		$Title.text = "Ctrl + " + str(Keybind.as_text())
	else :
		$Title.text = str(Keybind.as_text())

func _on_remove_pressed() -> void:
	Settings.SavedKeybinds[Event].erase(Keybind)
	InputMap.action_erase_event(Event, Keybind)
	queue_free()
