extends Node

@export var SceneItem: PackedScene
@onready var par = get_parent()
var Holding: = false

func _ready() -> void :
	if par is Button:
		par.connect("button_down", Callable(self, "ButtonDown"))
		par.connect("button_up", Callable(self, "ButtonUp"))

func ButtonUp():
	Holding = false
	User.emit_signal("StoppedDragging")
	if !User.DraggingObject:
		return
	System.AddObject(SceneItem, true, null, {}, true)
	User.DraggingObject = false

func ButtonDown():
	User.DraggedObject = SceneItem
	User.DraggingObject = true
	Holding = true
	User.emit_signal("StartedDragging")
