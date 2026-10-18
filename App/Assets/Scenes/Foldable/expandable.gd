extends Item

var Data: = {
	"Type": "Foldable", 
	"Pos": Vector2.ZERO, 
	"Size": Vector2.ZERO, 
	"ID": "Home", 
	"Title": "", 
	"TitleSize": Settings.Data["DefaultTitleSize"],
	"ItemID" : "",
	"Tags" : [],
	"Style" : ""
}

var Options := [
	
]

func _ready() -> void :
	initItem()

func SetTitle(title):
	$Container.title = title
