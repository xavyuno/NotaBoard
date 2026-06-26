extends Panel

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	$Key.text = Settings.UrlAPIKey

func _on_hide_pressed() -> void:
	$Key.secret = !$Key.secret
	Settings.UrlAPIKey = $Key.text

func _on_key_text_changed(new_text: String) -> void:
	Settings.UrlAPIKey = new_text
