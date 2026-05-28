extends VBoxContainer

@onready var input: LineEdit = $AddHolder / Input

var Data: = {
	"Type": "ToDo", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"List": {}, 
	"ID": "Home", 
	"TitleOn": true, 
	"Title": ""
}

func _ready() -> void :
	for i in Data["List"].keys():
		var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
		Check.Text = i
		Check.get_node("Input").set_pressed_no_signal(Data["List"][i])
		$List.add_child(Check)
	UpdateValues($Title, "TitleOn", "visible")
	UpdateValues($Title, "Title", "text")

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["TitleOn"] = $Title.visible
	Data["Title"] = $Title.text

func AddList():
	if $AddHolder / Input.text.is_empty():
		return
	var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
	Check.Text = input.text
	$List.add_child(Check)
	Data["List"].merge({input.text: false}, true)
	$AddHolder / Input.text = ""

func _on_add_pressed() -> void :
	AddList()

func _on_input_text_submitted(new_text: String) -> void :
	AddList()

func _on_title_on_pressed() -> void :
	$Title.visible = !$Title.visible
