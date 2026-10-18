extends HBoxContainer

var CanDelete := true
var Name := ""

func _ready() -> void:
	$Delete.visible = CanDelete
	$Select.text = Name
	Customization.connect("ApplyCustomization", Apply)
	Apply()

func Apply():
	if Customization.DefaultTheme == Name:
		$Select/Default.visible = true
	else:
		$Select/Default.visible = false

func _on_delete_pressed() -> void:
	Customization.Remove(Name)
	Customization.emit_signal("Reload")
	Customization.emit_signal("ApplyCustomization")

func _on_set_pressed() -> void:
	if Customization.Styles.has(Name):
		Customization.DefaultStyle = Name
	Customization.emit_signal("Reload")
	Customization.emit_signal("ApplyCustomization")
