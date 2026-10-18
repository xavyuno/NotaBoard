extends Control

func _ready() -> void:
	var file = FileAccess.open("res://Updates.txt", FileAccess.READ)
	$Changelog/ScrollContainer/Notes.text = file.get_as_text()
	file.close()

	Settings.connect("SettingsChanged", SettingsChanged)

func SettingsChanged():
	pass


func _on_notes_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
