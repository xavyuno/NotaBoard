extends Control

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "settingChanged"))

func settingChanged():
	$Center.visible = Settings.ShowCenter
