extends HBoxContainer

var PrevTitle := ""
var PrevID := ""

func _ready() -> void :
	User.connect("ChangeBoard", Callable(self, "ChangedBoard"))

func _on_button_pressed() -> void :
	User.emit_signal("ChangeBoard", PrevID, PrevTitle)

func ChangedBoard(Board: String, Title: String):
	if Board == "Settings":
		return
	if Board != "Home":
		if User.Boards[Board]["ID"] != "Home":
			PrevTitle = User.Boards[User.Boards[Board]["ID"]]["Title"]
			PrevID = User.Boards[Board]["ID"]
			if PrevTitle.is_empty():
				PrevTitle = "Untitled Board: " + PrevID
			$Home.text = PrevTitle + "/"
		else :
			$Home.text = "Home/"
			PrevTitle = "Home"
			PrevID = "Home"
	else :
		$Home.text = "Home/"
		PrevTitle = "Home"
		PrevID = "Home"
	if Board.similarity("Home") == 1:
		$NewBoard.visible = false
		$Home.visible = false
	else:
		$Home.visible = true
		var tempTitle = Title
		if tempTitle.is_empty():
			tempTitle = "Untitled Board: " + Board
		$NewBoard.text = tempTitle
		$NewBoard.visible = true
