extends Button

@export var par = get_parent()

func _ready() -> void :
    connect("pressed", Callable(self, "Clicked"))

func Clicked():
    User.emit_signal("ObjectRemoved", par.Data)
    par.queue_free()
