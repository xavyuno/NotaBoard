extends Control

@onready var update: Button = $Update

func _ready() -> void :
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))
	var ver = FileAccess.open("res://LatestVersion.txt", FileAccess.READ).get_as_text()
	ver = ver.strip_edges(true, true)
	ver = ver.strip_escapes()
	$Version.text = "Version: " + ver.validate_filename()

func SettingsChanged():
	$Holder.current_tab = Settings.Data["LastSettings"]

func _on_project_dir_pressed() -> void :
	OS.shell_open(ProjectSettings.globalize_path("user://"))

func _on_project_link_pressed() -> void :
	OS.shell_open("https://github.com/xavyuno/Task-Manager")

func _on_holder_tab_changed(tab: int) -> void:
	Settings.Data["LastSettings"] = tab
