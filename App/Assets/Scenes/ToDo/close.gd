extends Button

@export var par = get_parent()

func _ready() -> void :
	connect("pressed", Callable(self, "Clicked"))

func Clicked():
	par.queue_free()
