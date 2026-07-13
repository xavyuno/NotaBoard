extends HBoxContainer

var Text := ""
var Date := [0, 0, 0]
var ID := 0

func _ready() -> void:
	$Input.text = Text

func _on_remove_pressed() -> void:
	if User.SavedEvents.has(System.DateToString(Date)):
		User.SavedEvents[System.DateToString(Date)].erase($Input.text)
	queue_free()
	Settings.emit_signal("SettingsChanged")

func _on_input_text_changed() -> void:
	User.SavedEvents[System.DateToString(Date)][ID] = $Input.text
