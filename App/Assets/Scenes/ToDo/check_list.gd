extends HBoxContainer

var Text: = ""

func _ready() -> void :
	$Text.text = Text

func _on_input_toggled(toggled_on: bool) -> void :
	$"../..".Data["List"][$Text.text] = toggled_on
