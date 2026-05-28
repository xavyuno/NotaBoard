extends HBoxContainer

var Text: = ""

func _ready() -> void :
    $Input.text = Text


func _on_input_toggled(toggled_on: bool) -> void :
    $"../..".Data["List"][$Input.text] = toggled_on
    print(toggled_on)
