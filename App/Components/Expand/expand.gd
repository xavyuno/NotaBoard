extends Button

@export var par = get_parent()
var Dragging: = false
var DragMinOnly: = false
var DragYAxisOnly: = false

func _ready() -> void :
    connect("button_down", Callable(self, "ButtonDown"))
    connect("button_up", Callable(self, "ButtonUp"))
    if par != null and DragMinOnly:
        par.custom_minimum_size = par.size

func _input(event: InputEvent) -> void :
    if event is InputEventMouseMotion:
        if Dragging:
            if DragMinOnly:
                if DragYAxisOnly:
                    par.custom_minimum_size.y += event.relative.y / User.CamZoom
                    par.custom_minimum_size.y = clamp(par.custom_minimum_size.y, 20, 10000000000)
                else:
                    par.custom_minimum_size += event.relative / User.CamZoom
                    par.custom_minimum_size.clamp(Vector2(64, 64), Vector2(10000, 10000))
            else:
                par.size += event.relative / User.CamZoom

func ButtonDown():
    Dragging = true

func ButtonUp():
    Dragging = false
