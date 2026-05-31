extends VBoxContainer

var Data: = {
	"Type": "Board", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"Board": "Getting ID...", 
	"Title": "", 
	"ID": "Home", 
}

func _ready() -> void :
	UpdateValues($BoardName, "Title", "text")
	UpdateValues($New/ID, "Board", "text")


func UpdateValues(NODE, value, parameter):
	if Data.has(value):
		NODE.call_deferred("set", parameter, Data[value])

func GetData():
	return Data

func _process(delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size
	Data["Title"] = $BoardName.text

func _on_new_pressed() -> void :
	User.emit_signal("ChangeBoard", Data["Board"], Data["Title"])

func _on_board_name_text_changed(new_text: String) -> void :
	Data["Title"] = new_text

func _on_board_name_text_submitted(new_text: String) -> void :
	release_focus()
