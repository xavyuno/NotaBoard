extends HBoxContainer

@export var MainObject = get_parent()

func _ready() -> void :
    $Expand.par = MainObject
