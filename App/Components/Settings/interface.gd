extends Control


func _ready() -> void:
	Settings.connect("SettingsChanged", SettingsChanged)

func SettingsChanged():
	$Holder/BackgroundCol/BGPicker.color = Settings.Data["BackgroundCol"]
	$Holder/Center.text = "Show center of board: On" if Settings.Data["ShowCenter"] else "Show center of board: Off"
	$Holder/Center.alignment = HORIZONTAL_ALIGNMENT_CENTER if Settings.Data["ShowCenter"] else HORIZONTAL_ALIGNMENT_LEFT
	$Holder/SelectColor/Holder/SelectColor.color = Settings.Data["SelectCol"]
	$Holder/SelectColor/Holder/On.text = "On" if Settings.Data["CanSelectCol"] else "Off"
	$Holder/DragCol/DragColor.color = Settings.Data["DragCol"]
	$Holder/GridCol/GridCol.color = Settings.Data["GridCol"]

func _on_bg_picker_color_changed(color: Color) -> void:
	Settings.Data["BackgroundCol"] = color
	Settings.emit_signal("SettingsChanged")

func _on_center_pressed() -> void:
	Settings.Data["ShowCenter"] = !Settings.Data["ShowCenter"]
	Settings.emit_signal("SettingsChanged")


func _on_select_color_color_changed(color: Color) -> void:
	Settings.Data["SelectCol"] = color
	Settings.emit_signal("SettingsChanged")

func _on_drag_color_color_changed(color: Color) -> void:
	Settings.Data["DragCol"] = color

func _on_grid_col_color_changed(color: Color) -> void:
	Settings.Data["GridCol"] = color
	Settings.emit_signal("SettingsChanged")


func _on_grid_scale_value_changed(value: float) -> void:
	Settings.Data["GridSize"] = value * 16
