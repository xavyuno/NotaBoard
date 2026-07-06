extends HBoxContainer

var Text: = ""

func _ready() -> void :
	$Text.text = Text

func ChangeFontSize(value):
	$Text.add_theme_font_size_override("font_size", value)

func _on_input_toggled(toggled_on: bool) -> void :
	$"../..".Data["List"][$Text.text] = toggled_on
	$"../..".CalculateProgress()

func _on_text_pressed() -> void:
	$Input.button_pressed = !$Input.button_pressed
