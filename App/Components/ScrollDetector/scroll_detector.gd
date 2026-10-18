extends Node

@onready var Parent : ScrollContainer = get_parent()

func _ready() -> void:
	Parent = get_parent()
	Parent.connect("mouse_entered", MouseEntered)
	Parent.connect("mouse_exited", MouseExited)

func MouseEntered():
	if Parent.get_v_scroll_bar().max_value - Parent.size.y >= 1:
		User.InFocus = true

func MouseExited():
	User.InFocus = false
