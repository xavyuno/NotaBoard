extends Panel

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	$Key.text = Settings.Data["ShareAPI"]

func _on_hide_pressed() -> void:
	$Key.secret = !$Key.secret
	Settings.Data["ShareAPI"] = $Key.text

func _on_key_text_changed(new_text: String) -> void:
	Settings.Data["ShareAPI"] = new_text

func _on_info_meta_clicked(meta: Variant) -> void:
	OS.shell_open(str(meta))
