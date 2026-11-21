extends Item

var Data: = {
	"Type": "MediaPlayer", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"ItemID" : -1,
	"Tags" : [],
	"Style" : "",
}

var Options := [

]

func _ready() -> void :
	initItem()
	ApplyData()

func ApplyData():
	pass

func _process(_delta: float) -> void :
	Data["Pos"] = position
	Data["Size"] = size


func _on_button_pressed() -> void:
	$Button/FileDialog.popup(Rect2(200, 200, 200, 200))

func _on_file_dialog_file_selected(path: String) -> void:
	var Path = ProjectSettings.globalize_path(path)
	var vid = VideoStreamTheora.new()
	vid.set_path_cache(path)
	$VideoStreamPlayer.stream = vid
