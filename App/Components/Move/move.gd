extends Button

@export var par = get_parent()
var Dragging: = false

func _ready() -> void :
	connect("button_down", Callable(self, "ButtonDown"))
	connect("button_up", Callable(self, "ButtonUp"))

func _input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		if Dragging:
			par.position += event.relative / User.CamZoom

func ButtonDown():
	Dragging = true

func ButtonUp():
	Dragging = false
