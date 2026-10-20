extends Control

@onready var Command = $"../General/Commands"

func _ready() -> void:
	Settings.connect("SettingsChanged", Refresh)

func Refresh():
	for i in Command.get_node("ScrollCommands/Holder").get_children():
		i.queue_free()
	var ID = 0
	for i in Settings.Data["NoteCommands"].size():
		var data : Dictionary= Settings.Data["NoteCommands"][i]
		var butt = preload("res://App/Components/CommandBox/command_box.tscn").instantiate()
		butt.Keyword = data.keys()[0]
		butt.Command = data.values()[0]
		butt.ID = i
		Command.get_node("ScrollCommands/Holder").add_child(butt)

func _on_add_command_pressed() -> void:
	Execute()

func Execute():
	if Settings.Data["NoteCommands"] is Dictionary:
		Settings.Data["NoteCommands"] = []
	Settings.Data["NoteCommands"].append(
	{Command.get_node("AddCommand/Keyword").text : Command.get_node("AddCommand/Command").text})
	Refresh()
	Settings.emit_signal("SettingsChanged")


func _on_command_text_submitted(_new_text: String) -> void:
	Execute()

func _on_keyword_text_submitted(_new_text: String) -> void:
	Execute()
