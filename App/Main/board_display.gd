extends HBoxContainer

@onready var home: Button = $Home
@onready var previous: Button = $Previous

var PrevTitle := ""
var PrevID := ""

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))
	for i in get_children():
		i.visible = false

func ChangedBoard(Board: String, Title: String):
	if Board == "Settings":
		home.visible = true
		home.text = "Home"
		previous.visible = false
		return
	if Board != "Home":
		if User.Boards[Board]["ID"] != "Home":
			PrevTitle = User.Boards[User.Boards[Board]["ID"]]["Title"]
			PrevID = User.Boards[Board]["ID"]
			if PrevTitle.is_empty():
				PrevTitle = "Untitled Board: " + PrevID
			previous.text = PrevTitle + "/"
			home.text = "Home/.../"
			home.visible = true
			previous.visible = true
		else :
			home.text = "Home/"
			previous.text = "Home/"
			PrevTitle = "Home"
			PrevID = "Home"
			home.visible = true
			previous.visible = false
	else :
		previous.text = "Home/"
		PrevTitle = "Home"
		PrevID = "Home"
		home.text = "Home/"
		home.visible = true
		previous.visible = false
	if Board.similarity("Home") == 1:
		$NewBoard.visible = false
		previous.visible = false
		home.visible = false
	else:
		var tempTitle = Title
		if tempTitle.is_empty():
			tempTitle = "Untitled Board: " + Board
		$NewBoard.text = tempTitle
		$NewBoard.visible = true
	User.PreviousPage = PrevID
	User.PreviousTitle = PrevTitle

func _on_home_pressed() -> void:
	User.emit_signal("ChangeBoard", "Home", "Home")

func _on_previous_pressed() -> void:
	User.emit_signal("ChangeBoard", PrevID, PrevTitle)
