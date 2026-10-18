extends Control

func _ready() -> void:
	Settings.connect("SettingsChanged", Callable(self, "SettingsChanged"))

func SettingsChanged():
	$DefaultValues/ProgressiveLoading/LoadDur.value = Settings.Data["LoadDur"]
	$DefaultValues/ItemLimit.value = Settings.Data["ItemLimit"]
	$DefaultValues/ItemLimit.prefix = "Total items: " + str(Settings.Data["TotalItems"]) + " | Max: "
	$DefaultValues/ProgressiveLoading/Proload.text = "On" if Settings.Data["ProgressiveLoading"] else "Off"
	$DefaultValues/DefaultFontSize.value = Settings.Data["DefaultFontSize"]
	$DefaultValues/DefaultTitle.value = Settings.Data["DefaultTitleSize"]

func _on_update_id_pressed() -> void:
	User.emit_signal("ForceUpdateID")


func _on_load_dur_value_changed(value: float) -> void:
	Settings.Data["LoadDur"] = value

func _on_item_limit_value_changed(value: float) -> void:
	Settings.Data["ItemLimit"] = value

func _on_default_font_size_value_changed(value: float) -> void:
	Settings.Data["DefaultFontSize"] = int(value)
	Settings.emit_signal("SettingsChanged")

func _on_default_title_value_changed(value: float) -> void:
	Settings.Data["DefaultTitleSize"] = int(value)
	Settings.emit_signal("SettingsChanged")

func _on_proload_pressed() -> void:
	Settings.Data["ProgressiveLoading"] = !Settings.Data["ProgressiveLoading"]
	Settings.emit_signal("SettingsChanged")
