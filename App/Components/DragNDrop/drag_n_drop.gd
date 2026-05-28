extends Node

@export var Item: PackedScene
@onready var par = get_parent()
var Holding: = false

func _ready() -> void :
	if par is Button:
		par.connect("button_down", Callable(self, "ButtonDown"))
		par.connect("button_up", Callable(self, "ButtonUp"))

func ButtonUp():
	Holding = false
	User.emit_signal("StoppedDragging")
	if !User.MouseInCanvas or !User.DraggingObject:
		return
	System.AddObject(Item, true, null, {}, true)
	User.DraggingObject = false

func ButtonDown():
	User.DraggedObject = Item
	User.DraggingObject = true
	Holding = true
	User.emit_signal("StartedDragging")
