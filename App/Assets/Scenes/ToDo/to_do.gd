extends VBoxContainer

@onready var input: LineEdit = $AddHolder / Input

var Data: = {
	"Type": "ToDo", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"List": {}, 
	"ID": "Home", 
	"TitleOn": true, 
	"Title": "",
	"FontSize" : Settings.DefaultFontSize,
	"TitleSize": Settings.DefaultTtileSize
}

var Options := [
	"Ratio",
	"Title",
	"FontSize",
	"TitleSize"
]
var TempTitleSize := 0

func _ready() -> void :
	for i in Data["List"].keys():
		var Check = preload("res://App/Assets/Scenes/ToDo/check_list.tscn").instantiate()
		Check.Text = i
		Check.get_node("Input").set_pressed_no_signal(Data["List"][i])
		$List.add_child(Check)
		Check.get_node("Close").connect("pressed", TodoClosed.bind(Check.get_path()))
	UpdateValues($Title, "TitleOn", "visible")
	UpdateValues($Title, "Title", "text")
	if Data.has("FontSize"):
		$Title.add_theme_font_size_override("font_size", Data["TitleSize"])
		if $List.get_children().size() >= 1:
			for i in $List.get_children():
				i.ChangeFontSize(Data["FontSize"])

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func TodoClosed(path):
	TempTitleSize = $Title.size.y
	size.y -= get_node(path).size.y
	get_node(path).queue_free()
	$Title.size.y = TempTitleSize
	Data["List"].erase(get_node(path).Text)

func ChangeTitleSize(value : int):
	$Title.add_theme_font_size_override("font_size", value)
	Data["TitleSize"] = value

func ChangeFontSize(value : int):
	if Data.has("FontSize"):
		if $List.get_children().size() >= 1:
			for i in $List.get_children():
				i.ChangeFontSize(Data["FontSize"])
	Data["FontSize"] = value

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
	Check.get_node("Close").connect("pressed", TodoClosed.bind(Check.get_path()))
	Data["List"].merge({input.text: false}, true)
	$AddHolder / Input.text = ""
	$AddHolder/Input.grab_click_focus()

func _on_add_pressed() -> void :
	AddList()

func _on_input_text_submitted(new_text: String) -> void :
	AddList()

func _on_title_on_pressed() -> void :
	$Title.visible = !$Title.visible
