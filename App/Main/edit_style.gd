extends Panel

var ThemesPath = "user://Themes/"

func _ready() -> void:
	Customization.connect("Reload", Reload)
	Settings.connect("SettingsChanged", SettingsChanged)
	Customization.connect("ApplyTheme", ApplyTheme)

func ApplyTheme():
	if Settings.Data["LoadSystemTheme"]:
		ThemeColor(Customization.Themes["Application Default"]["FontColor"])
		var APPLICATION_THEME = preload("uid://ddsma7l66depl")
		APPLICATION_THEME.default_font = System.LoadFont(Customization.Themes["Application Default"]["Font"])

func SettingsChanged():
	if Settings.Data["Themes"] != {}:
		Customization.Themes.merge(Settings.Data["Themes"], true)
	Apply("")
	const APPLICATION_STYLE = preload("res://App/Resources/ApplicationStyle.tres")
	APPLICATION_STYLE.copy_from_resource(Customization.Themes["Application Default"]["Style"])
	Customization.Themes["Application Default"]["Style"] = APPLICATION_STYLE

func Apply(Alter):
	Settings.Data["Themes"] = Customization.Themes
	for i in [$PreviewButton, $PreviewText]:
		if Alter == "" or Alter == "Style":
			for j in System.GetStyleOptions(i):
				i.add_theme_stylebox_override(j, Customization.Themes[Customization.SelectedTheme]["Style"])
		if Alter == "" or Alter == "Font":
			var font = System.LoadFont(Customization.Themes[Customization.SelectedTheme]["Font"])
			for j in System.GetFontOptions(i):
				i.add_theme_font_override(j, font)
		if Alter == "" or Alter == "FontColor":
			for j in System.GetFontColors(i):
				if Customization.Themes[Customization.SelectedTheme].has("FontColor"):
					i.add_theme_color_override(j, Customization.Themes[Customization.SelectedTheme]["FontColor"])

func Reload():
	Settings.Data["Themes"] = Customization.Themes
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBoxEmpty:
		$ScrollContainer.visible = false
		return
	else:
		$ScrollContainer.visible = true
	var Holders = [$ScrollContainer/Holder/Border/Holder/BorderWidth/Holder,
	$ScrollContainer/Holder/ExpandMargins/Holder,
	$ScrollContainer/Holder/CornerRadius/Holder,
	$ScrollContainer/Holder/ContentMargins/Holder
	]
	for i in Holders:
		for j in i.get_children():
			j.queue_free()
	var AlterType = ["set_border_width", "set_expand_margin", "set_corner_radius", "set_content_margin"]
	var Sides = ["Left", "Top", "Right", "Bottom"]
	for i in Holders.size():
		for j in Sides.size():
			if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBox:
				var SB = SpinBox.new()
				SB.prefix = Sides[j]
				SB.value = Customization.Themes[Customization.SelectedTheme]["Style"].call(AlterType[i].replace("set", "get"), j)
				SB.suffix = "px"
				Holders[i].add_child(SB)
				SB.connect("value_changed", AlterStyle.bind(AlterType[i], j))
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBox:
		$ScrollContainer/Holder/Border/Holder/BorderColor.color = Customization.Themes[Customization.SelectedTheme]["Style"].border_color
		$ScrollContainer/Holder/Border/Holder/BorderBlend.button_pressed = Customization.Themes[Customization.SelectedTheme]["Style"].border_blend
		$ScrollContainer/Holder/CornerDetail.value = Customization.Themes[Customization.SelectedTheme]["Style"].corner_detail
		$ScrollContainer/Holder/BGCol/BgColor.color = Customization.Themes[Customization.SelectedTheme]["Style"].bg_color
		$Info.text = "Selected " + Customization.SelectedTheme
	if Customization.Themes[Customization.SelectedTheme].has("FontColor"):
		$ScrollContainer/Holder/FontCol/FontCol.color = Customization.Themes[Customization.SelectedTheme]["FontColor"]
	$ScrollContainer/Holder/Font/FontPath.text = Customization.Themes[Customization.SelectedTheme]["Font"] if Customization.Themes[Customization.SelectedTheme]["Font"] is String else ""
	for i in $StyleScroll/Holder.get_children():
		i.queue_free()
	for i in Customization.Themes.keys():
		var butt = preload("res://App/Components/Settings/style_holder.tscn").instantiate()
		butt.Name = i
		if i in ["Default", "Empty", "LightMode", "Outline", "Application Default"]:
			butt.CanDelete = false
		butt.get_node("Select").connect("pressed", SelectStyle.bind(i))
		$StyleScroll/Holder.add_child(butt)
	

func AlterStyle(value : float, Type : String, Index : int):
	$Info.text = "Selected " + Customization.SelectedTheme
	Customization.Themes[Customization.SelectedTheme]["Style"].call(Type, Index, value)
	Customization.emit_signal("ApplyCustomization", "Style")
	Apply("Style")

func _on_new_pressed() -> void:
	if $StyleName.text != "":
		Customization.Themes.merge({$StyleName.text : {
			"Style" : Customization.Themes[Customization.DefaultTheme]["Style"].duplicate(true),
			"Font" : ""
		}}, true)
		Reload()
		Customization.emit_signal("Reload")

func SelectStyle(Name : String):
	Customization.SelectedTheme = Name
	Reload()
	Apply("")

func _on_border_color_color_changed(color: Color) -> void:
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBoxFlat:
		Customization.Themes[Customization.SelectedTheme]["Style"].border_color = color
		Apply("Style")

func _on_border_blend_toggled(toggled_on: bool) -> void:
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBoxFlat:
		Customization.Themes[Customization.SelectedTheme]["Style"].border_blend = toggled_on
		Customization.emit_signal("ApplyCustomization", "Style")
		Apply("Style")

func _on_bg_color_color_changed(color: Color) -> void:
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBoxFlat:
		Customization.Themes[Customization.SelectedTheme]["Style"].bg_color = color
		Apply("Style")

func _on_bg_color_popup_closed() -> void:
	Customization.emit_signal("ApplyCustomization", "Style")
	Apply("Style")

func _on_border_color_popup_closed() -> void:
	Customization.emit_signal("ApplyCustomization", "Style")
	Apply("Style")

func _on_open_folder_pressed() -> void:
	$ScrollContainer/Holder/Font/FileDialog.current_dir = OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS)
	$ScrollContainer/Holder/Font/FileDialog.popup(Rect2(500, 500, 500, 500))

func _on_file_dialog_file_selected(path: String) -> void:
	$ScrollContainer/Holder/Font/FontPath.text = path
	if Customization.SelectedTheme == "Application Default":
		var APPLICATION_THEME = preload("uid://ddsma7l66depl")
		APPLICATION_THEME.default_font = System.LoadFont(path)
	else:
		Customization.emit_signal("ApplyCustomization", "Font")
	Customization.Themes[Customization.SelectedTheme]["Font"] = path
	Apply("Style")

func _on_font_path_text_changed(new_text: String) -> void:
	if Customization.SelectedTheme == "Application Default":
		var APPLICATION_THEME = preload("uid://ddsma7l66depl")
		APPLICATION_THEME.default_font = System.LoadFont(new_text)
	else:
		Customization.emit_signal("ApplyCustomization", "Font")
	Customization.Themes[Customization.SelectedTheme]["Font"] = new_text
	Apply("Font")

func _on_hide_pressed() -> void:
	$ScrollContainer/Holder/Font/FontPath.secret = !$ScrollContainer/Holder/Font/FontPath.secret

func _on_corner_detail_value_changed(value: float) -> void:
	if Customization.Themes[Customization.SelectedTheme]["Style"] is StyleBoxFlat:
		Customization.Themes[Customization.SelectedTheme]["Style"].corner_detail = value
		Apply("Style")

func _on_corner_detail_focus_exited() -> void:
	Customization.emit_signal("ApplyCustomization", "Style")

func _on_font_col_color_changed(color: Color) -> void:
	Customization.Themes[Customization.SelectedTheme]["FontColor"] = color
	Apply("FontColor")

func _on_font_col_popup_closed() -> void:
	if Customization.SelectedTheme == "Application Default":
		ThemeColor($ScrollContainer/Holder/FontCol/FontCol.color)
	Customization.emit_signal("ApplyCustomization", "FontColor")
	Apply("FontColor")

func ThemeColor(color):
	if !Settings.Data["LoadSystemTheme"]:
		return
	System.CreateNotif("Loading Font Color...")
	const APPLICATION_THEME = preload("uid://ddsma7l66depl")
	for i in APPLICATION_THEME.get_color_type_list():
		for j in APPLICATION_THEME.get_color_list(i):
			if Settings.Data["ProgressiveLoading"]:
				await get_tree().create_timer(0.1).timeout
			APPLICATION_THEME.set_color(j, i, color)
