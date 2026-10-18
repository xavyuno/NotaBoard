extends HBoxContainer

var ID := 0
var Keyword := ""
var Command := ""

func Refresh():
	$Keyword.text = Keyword
	$Command.text = Command

func _ready() -> void:
	Refresh()

func _on_remove_pressed() -> void:
	Settings.Data["NoteCommands"].remove_at(ID)
	Settings.emit_signal("SettingsChanged")

func _on_command_text_changed(new_text: String) -> void:
	Command = new_text
	Settings.Data["NoteCommands"][ID] = {Keyword : Command}

func _on_keyword_text_changed(new_text: String) -> void:
	Keyword = new_text
	Settings.Data["NoteCommands"][ID] = {Keyword : Command}
