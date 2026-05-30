extends Node

@export var Par = get_parent()
var Selected := false
var Action := ""

func _ready() -> void :
	User.connect("StoppedSelecting", Callable(self, "StoppedSelecting"))
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

func StoppedSelecting():
	Selected = false
	Action = ""

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Click") and (Action == "Moving" or Action == "Resizing"):
		Action = ""
	if Input.is_action_just_pressed("Move") and Selected:
		if Action != "Moving":
			Action = "Moving"
		else :
			Action = ""
	if Input.is_action_just_pressed("Resize") and Selected:
		if Action != "Resizing":
			Action = "Resizing"
		else :
			Action = ""

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if Action == "Moving":
			Par.position += event.relative / User.CamZoom
		if Action == "Resizing" :
			Par.size += event.relative / User.CamZoom

func FocusEntered():
	print("Focus for " + Par.name + " entered")
	if User.MultiSelecting:
		if !(Par.get_path() in User.MultiSelectedObjects):
			User.MultiSelectedObjects.append(Par.get_path())
			Selected = true
		User.SelectedObject = null
	else:
		User.MultiSelectedObjects = []
		User.SelectedObject = Par.get_path()
		Selected = true
	User.emit_signal("SaveObjectData")

func FocusExted():
	print("Focus for " + Par.name + " exited")
	User.emit_signal("SaveObjectData")
	if !User.MultiSelecting:
		Selected = false
		Action = ""
