extends Node

@export var Par = get_parent()

func _ready() -> void :
	for i in Par.get_children(true):
		if i.get_child_count() >= 1:
			for j in i.get_children(true):
				if j.has_signal("focus_entered"):
					j.connect("focus_entered", Callable(self, "FocusEntered"))
				if j.has_signal("focus_exited"):
					j.connect("focus_exited", Callable(self, "FocusExited"))
		if i.has_signal("focus_entered"):
			i.connect("focus_entered", Callable(self, "FocusEntered"))
		if i.has_signal("focus_exited"):
			i.connect("focus_exited", Callable(self, "FocusExited"))

func FocusEntered():
	print("Focus for " + Par.name + " entered")
	if User.MultiSelecting:
		if !(Par.get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(Par.get_path())
		User.SelectedObject = null
	else:
		User.MultiSelectedObjects = []
		User.SelectedObject = Par.get_path()
	User.emit_signal("SaveObjectData")

func FocusExted():
	print("Focus for " + Par.name + " exited")
	User.emit_signal("SaveObjectData")
