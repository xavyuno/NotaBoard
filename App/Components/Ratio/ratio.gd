extends Button

@export var par = get_parent()
@export var SizePar = get_parent()

func _ready() -> void :
	connect("pressed", Callable(self, "Pressed"))

func Pressed():
	var Lowest: float = par.size.x
	if par.size.y < Lowest:
		Lowest = par.size.y
	if !SizePar:
		par.size = Vector2(Lowest, Lowest)
	else :
		SizePar.size = Vector2(Lowest, Lowest)
