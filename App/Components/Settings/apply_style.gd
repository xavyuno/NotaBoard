extends Panel

var SelectedItem := ""
var SelectedStyle := ""

func _ready() -> void:
	Settings.connect("SettingsChanged", SettingsChanged)
	Customization.connect("Reload", SettingsChanged)

func SettingsChanged():
	Customization.Config.merge(Settings.Data["ConfigStyles"], true)
	$Select/Item.clear()
	$ApplyStyle/Style.clear()
	for i in Customization.Config.keys():
		$Select/Item.add_item(i)
	$Select/Item.select(0)
	for i in Customization.Themes.keys():
		$ApplyStyle/Style.add_item(i)
	$ApplyStyle/Style.select(0)

func Apply():
	Settings.Data["ConfigStyles"] = Customization.Config

func _on_item_item_selected(index: int) -> void:
	SelectedItem = Customization.Config.keys()[index]
	for i in $ApplyStyle/Style.item_count:
		if $ApplyStyle/Style.get_item_text(i) == Customization.Config[SelectedItem]:
			$ApplyStyle/Style.select(i)
	Apply()

func _on_style_item_selected(index: int) -> void:
	SelectedStyle = Customization.Themes.keys()[index]
	Apply()

func _on_apply_pressed() -> void:
	Customization.Config[SelectedItem] = SelectedStyle
	Apply()
	Customization.emit_signal("ApplyCustomization")
