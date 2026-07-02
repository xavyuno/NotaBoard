extends Control

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "settingChanged"))

func settingChanged():
	$Center.visible = Settings.ShowCenter

func _on_clean_timeout() -> void:
	if name.contains("@"):
		queue_free()
