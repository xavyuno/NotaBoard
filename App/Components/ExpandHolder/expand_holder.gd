extends HBoxContainer

@export var Par = get_parent()

func _ready() -> void :
	$Expand.par = Par
