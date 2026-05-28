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
    User.Boards.append(str(User.Boards.size()))
    var tempBoard = preload("res://App/Assets/Scenes/Board/board.tscn")
    var tempData = tempBoard.instantiate().Data
    tempData["Board"] = str(User.Boards.size())
    System.AddObject(Item, true, null, tempData, true)
    User.DraggingObject = false

func ButtonDown():
    User.DraggedObject = Item
    User.DraggingObject = true
    Holding = true
    User.emit_signal("StartedDragging")
