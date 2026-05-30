extends VBoxContainer

var Data: = {
	"Type": "Notes", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Note": "", 
	"ID": "Home", 
	"Title": "", 
	"TitleOn": true, 
	"NoteOn": true
}

func _ready() -> void :
	UpdateValues($ScrollContainer / Notes, "Note", "text")
	UpdateValues($ScrollContainer, "NoteOn", "visible")
	UpdateValues($Title, "Title", "text")
	UpdateValues($Title, "TitleOn", "visible")

func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Note"] = $ScrollContainer / Notes.text
	Data["Title"] = $Title.text
	Data["TitleOn"] = $Title.visible
	Data["NoteOn"] = $ScrollContainer.visible

func ExtraUI(view: bool):
	$OptionsHolder.visible = view
	$ExpandHolder.visible = view

func _on_title_on_pressed() -> void :
	$Title.visible = !$Title.visible

func _on_note_on_pressed() -> void :
	$ScrollContainer.visible = !$ScrollContainer.visible
