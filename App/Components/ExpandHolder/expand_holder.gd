extends HBoxContainer

@export var Par = get_parent()

func _ready() -> void :
	$Expand.par = Par
	User.connect("ChangedOptionsBar", Callable(self, "ChangedOptionsBar"))
	visible = Settings.OptionsEnabled

func ChangedOptionsBar():
	visible = Settings.OptionsEnabled
