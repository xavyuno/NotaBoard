@tool
extends HBoxContainer

func _ready() -> void:
	$Remove.connect("pressed", Callable(self, "Pressed"))

func UpdateData(taskinfo, value):
	$Info.text = taskinfo
	$Info.button_pressed = value

func Pressed() -> void:
	queue_free()
