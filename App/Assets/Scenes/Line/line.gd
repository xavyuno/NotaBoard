extends Control

@onready var p_1: Button = $P1
@onready var p_2: Button = $P2

var Dragging: = false
var DraggingNode = null

var Data: = {
	"Type": "Line", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Point1": Vector2.ZERO, 
	"Point2": Vector2(100, 0)
}

var Options := []

func _ready() -> void :
	UpdateValues(p_1, "Point1", "position")
	UpdateValues(p_2, "Point2", "position")
	for i in [$P1, $P2]:
		i.connect("button_down", ButtonDown.bind(i))
		i.connect("button_up", Callable(self, "ButtonUp"))

func UpdateValues(NODE, value, parameter):
	if Settings.ProgressiveLoading:
		await get_tree().create_timer(User.LoadDur).timeout
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Point1"] = p_1.position
	Data["Point2"] = p_2.position

func _input(event: InputEvent) -> void :
	if event is InputEventMouseMotion:
		if Dragging:
			queue_redraw()
			DraggingNode.position += event.relative / User.CamZoom

func _draw() -> void :
	draw_line(Data["Point1"], Data["Point2"], Color.RED, 5)

func ButtonDown(button):
	DraggingNode = button
	Dragging = true

func ButtonUp():
	Dragging = false
	queue_redraw()
